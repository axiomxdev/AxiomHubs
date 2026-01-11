#!/usr/bin/env python3
import sys
import re

def add_print_statements(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    paren_level = 0  # ()
    bracket_level = 0  # []
    brace_level = 0  # {}
    in_multiline_comment = False
    in_multiline_string = False
    
    for i, line in enumerate(lines, 1):
        new_lines.append(line)
        
        # Détecter les commentaires multi-lignes --[[ et ]]
        if '--[[' in line:
            in_multiline_comment = True
        if ']]' in line and in_multiline_comment:
            in_multiline_comment = False
            continue
            
        # Sauter si on est dans un commentaire multi-ligne
        if in_multiline_comment:
            continue
        
        # Détecter les strings multi-lignes [[ et ]]
        if '[[' in line and not line.strip().startswith('--'):
            in_multiline_string = True
        if ']]' in line and in_multiline_string:
            in_multiline_string = False
            continue
            
        # Sauter si on est dans une string multi-ligne
        if in_multiline_string:
            continue
        
        # Nettoyer la ligne des commentaires simples et strings
        clean_line = re.sub(r'--.*', '', line)
        clean_line = re.sub(r'"[^"]*"', '', clean_line)
        clean_line = re.sub(r"'[^']*'", '', clean_line)
        
        # Compter les niveaux d'imbrication
        paren_level += clean_line.count('(') - clean_line.count(')')
        bracket_level += clean_line.count('[') - clean_line.count(']')
        brace_level += clean_line.count('{') - clean_line.count('}')
        
        # Vérifier si la ligne contient des mots-clés à éviter
        stripped = line.strip()
        keywords_to_avoid = ['return', 'if ', 'elseif ', 'else', 'then', 'end', 'do', 'while', 'for', 'repeat', 'until', 'break']
        contains_keyword = any(stripped.startswith(kw) or f' {kw} ' in f' {stripped} ' for kw in keywords_to_avoid)
        
        # Ajouter print() seulement si toutes les conditions sont remplies
        if (i % 3 == 0 and 
            paren_level == 0 and 
            bracket_level == 0 and 
            brace_level == 0 and
            stripped and 
            not stripped.startswith('--') and
            not contains_keyword and
            not stripped.rstrip().endswith(',')):
            
            # Détecter l'indentation de la ligne actuelle
            indent = len(line) - len(line.lstrip())
            indent_str = ' ' * indent
            new_lines.append(f'{indent_str}print("ligne {i}")\n')
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print(f"✅ Fichier traité: {len(lines)} lignes lues, {len(new_lines)} lignes écrites")
    print(f"📊 Prints ajoutés: {len(new_lines) - len(lines)}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 add_prints.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    add_print_statements(input_file, output_file)
