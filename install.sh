#!/usr/bin/bash

mkdir -p ~/.local/share/aiprj
mkdir -p ~/.local/bin

cp -r .claude ~/.local/share/aiprj/
cp -r .gemini ~/.local/share/aiprj/
cp -r .kiro ~/.local/share/aiprj/

cp .gitignore.org ~/.local/share/aiprj/
cp .mcp.json ~/.local/share/aiprj/
cp AI_* ~/.local/share/aiprj/

cp aiprj ~/.local/bin/aiprj
chmod 755 ~/.local/bin/aiprj
