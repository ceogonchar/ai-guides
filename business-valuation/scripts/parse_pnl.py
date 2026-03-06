import sys
import json
import pandas as pd
import pdfplumber
import os

def parse_csv(file_path):
    # Пытаемся распарсить CSV файл
    try:
        df = pd.read_csv(file_path)
        # Упрощенная логика: ищем колонки, содержащие ключевые слова
        revenue = df[df.columns[df.columns.str.contains('Revenue|Income|Sales', case=False, na=False)]].sum().sum()
        cogs = df[df.columns[df.columns.str.contains('COGS|Cost of Goods', case=False, na=False)]].sum().sum()
        expenses = df[df.columns[df.columns.str.contains('Expense|Operating', case=False, na=False)]].sum().sum()
        
        # Если не нашли по колонкам, ищем в строках (типично для P&L экспортов из QuickBooks)
        if revenue == 0:
            for index, row in df.iterrows():
                row_str = str(row.values).lower()
                if 'revenue' in row_str or 'total income' in row_str:
                    revenue = pd.to_numeric(row[1:], errors='coerce').sum()
                elif 'cogs' in row_str or 'cost of goods' in row_str:
                    cogs = pd.to_numeric(row[1:], errors='coerce').sum()
                elif 'total expenses' in row_str or 'operating expenses' in row_str:
                    expenses = pd.to_numeric(row[1:], errors='coerce').sum()

        net_income = revenue - cogs - expenses
        return {
            "revenue": float(revenue),
            "cogs": float(cogs),
            "gross_profit": float(revenue - cogs),
            "operating_expenses": float(expenses),
            "net_income": float(net_income),
            "margins": float(net_income / revenue * 100) if revenue > 0 else 0.0,
            "trends": "stable" # Placeholder
        }
    except Exception as e:
        return {"error": str(e)}

def parse_pdf(file_path):
    # Пытаемся извлечь текст из PDF
    try:
        text = ""
        with pdfplumber.open(file_path) as pdf:
            for page in pdf.pages:
                text += page.extract_text() + "\n"
        
        # Очень базовый парсинг текста
        revenue = 0
        expenses = 0
        net_income = 0
        
        lines = text.split('\n')
        for line in lines:
            line_lower = line.lower()
            if 'total income' in line_lower or 'total revenue' in line_lower:
                numbers = [float(s.replace(',','').replace('$','')) for s in line.split() if s.replace(',','').replace('.','').replace('$','').isdigit()]
                if numbers: revenue = numbers[-1]
            elif 'total expenses' in line_lower or 'operating expenses' in line_lower:
                numbers = [float(s.replace(',','').replace('$','')) for s in line.split() if s.replace(',','').replace('.','').replace('$','').isdigit()]
                if numbers: expenses = numbers[-1]
            elif 'net income' in line_lower or 'net profit' in line_lower:
                numbers = [float(s.replace(',','').replace('$','')) for s in line.split() if s.replace(',','').replace('.','').replace('$','').isdigit()]
                if numbers: net_income = numbers[-1]
                
        if net_income == 0:
            net_income = revenue - expenses
            
        return {
            "revenue": float(revenue),
            "cogs": 0.0,
            "gross_profit": float(revenue),
            "operating_expenses": float(expenses),
            "net_income": float(net_income),
            "margins": float(net_income / revenue * 100) if revenue > 0 else 0.0,
            "trends": "stable"
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No file path provided"}))
        sys.exit(1)
        
    file_path = sys.argv[1]
    
    if not os.path.exists(file_path):
        print(json.dumps({"error": "File not found"}))
        sys.exit(1)
        
    ext = file_path.split('.')[-1].lower()
    
    if ext == 'csv':
        result = parse_csv(file_path)
    elif ext == 'pdf':
        result = parse_pdf(file_path)
    else:
        result = {"error": "Unsupported file format. Please provide CSV or PDF."}
        
    print(json.dumps(result, indent=2))
