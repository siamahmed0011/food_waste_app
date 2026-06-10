import re
import os

filepath = r'c:\Users\Acer\Desktop\Food App\food_waste_app\lib\screens\auth\admin_dashboard_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    text = f.read()

start_idx = text.find('recentActivity = [/* mock for now */]; // _buildRecentActivities(')
if start_idx != -1:
    end_idx = text.find(');', start_idx)
    if end_idx != -1:
        text = text[:start_idx] + 'recentActivity = [];' + text[end_idx+2:]

text = re.sub(r'class _StatCard extends StatelessWidget \{.*?\n\}', '', text, flags=re.MULTILINE|re.DOTALL)
text = re.sub(r'class _ErrorState extends StatelessWidget \{.*?\n\}', '', text, flags=re.MULTILINE|re.DOTALL)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(text)
print('Syntax fixed!')
