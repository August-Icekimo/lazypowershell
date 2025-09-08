#!/bin/sh
# 修改pvemanagerlib.js使其顯示節點溫度
# 已修正腳本邏輯，使其能夠正確執行
# Edit file 1 is $NODES_PM
export NODES_PM="/usr/share/perl5/PVE/API2/Nodes.pm"
# Edit file 2 is $pveManagerLib_JS
export pveManagerLib_JS="/usr/share/pve-manager/js/pvemanagerlib.js"

export ORG1='PVE::pvecfg::version_text();'
export ORG2='widget.pveNodeStatus'
export ORG3='pveversion',

# 檢查必要指令
for cmd in sensors grep sed cut diff; do
    command -v $cmd >/dev/null 2>&1 || { echo >&2 "需要 '$cmd' 但未安裝。正在中止。"; exit 1; }
done

# Backup original files
cp $NODES_PM ${NODES_PM}.old
cp $pveManagerLib_JS ${pveManagerLib_JS}.old

# find $ORG1 is which line of $NODES_PM, store in $insertLine
insertLine=$(cat $NODES_PM | grep -n "$ORG1" | cut -d: -f1)
echo $insertLine

# find $ORG2 is which line of $pveManagerLib_JS, store in $insertLine2
insertLine2=$(cat $pveManagerLib_JS | grep -n "$ORG2" | cut -d: -f1)
echo $insertLine2

# find $ORG3 is which line of $pveManagerLib_JS, store in $insertLine3
insertLine3=$(cat $pveManagerLib_JS | grep -n "$ORG3" | cut -d: -f1)
echo $insertLine3

# --- 修正檔案修改邏輯 ---

# 1. 修改 Perl 檔案 (Nodes.pm)，加入執行 sensors 指令的程式碼
sed -i "${insertLine}a \$res->{thermalstate} = \`sensors\`;" "$NODES_PM"

# 2. 修改 JavaScript 檔案 (pvemanagerlib.js)，加入顯示溫度的 UI 元件
sed -i "${insertLine2}a \        ,{\n            itemId: 'thermal',\n            colspan: 2,\n            printBar: false,\n            title: gettext('Node Thermal State'),\n            textField: 'thermalstate',\n            renderer: function(value) {\n                if (!value) { return ''; }\n                const c0 = value.match(/Tctl: *\\+([\\d\\.]+)/) ? value.match(/Tctl: *\\+([\\d\\.]+)/)[1] : 'N/A';\n                const n0 = value.match(/Composite: *\\+([\\d\\.]+)/) ? value.match(/Composite: *\\+([\\d\\.]+)/)[1] : 'N/A';\n                const n1 = value.match(/Sensor 2: *\\+([\\d\\.]+)/) ? value.match(/Sensor 2: *\\+([\\d\\.]+)/)[1] : 'N/A';\n                const g0 = value.match(/edge: *\\+([\\d\\.]+)/) ? value.match(/edge: *\\+([\\d\\.]+)/)[1] : 'N/A';\n                return \`CPU: \${c0}°C | SSD: \${n0}°C, \${n1}°C | GPU: \${g0}°C\`;\n            }\n        }" "$pveManagerLib_JS"

# --- 以下為上方 sed 指令所插入的 JavaScript 程式碼，供參考 ---
# ,{
#     itemId: 'thermal',
#     colspan: 2,
#     printBar: false,
#     title: gettext('Node Thermal State'),
#     textField: 'thermalstate',
#     renderer: function(value) {
#         if (!value) { return ''; }
#         const c0 = value.match(/Tctl: *\+([\d\.]+)/) ? value.match(/Tctl: *\+([\d\.]+)/)[1] : 'N/A';
#         const n0 = value.match(/Composite: *\+([\d\.]+)/) ? value.match(/Composite: *\+([\d\.]+)/)[1] : 'N/A';
#         const n1 = value.match(/Sensor 2: *\+([\d\.]+)/) ? value.match(/Sensor 2: *\+([\d\.]+)/)[1] : 'N/A';
#         const g0 = value.match(/edge: *\+([\d\.]+)/) ? value.match(/edge: *\+([\d\.]+)/)[1] : 'N/A';
#         return `CPU: ${c0}°C | SSD: ${n0}°C, ${n1}°C | GPU: ${g0}°C`;
#     }
# }
# --- 程式碼參考結束 ---

# 3. 修改 JavaScript 檔案 (pvemanagerlib.js)，將新的欄位 'thermalstate' 加入 fields 列表
sed -i "${insertLine3}a \            'thermalstate'," "$pveManagerLib_JS"

# restart pveproxy service
echo "Restart PVE Proxy service"
sudo systemctl restart pveproxy

# Generate diff files
diff ${NODES_PM}.old $NODES_PM > ${NODES_PM}.diff
diff ${pveManagerLib_JS}.old $pveManagerLib_JS > ${pveManagerLib_JS}.diff.tmp
# 移除 diff 中因 sed 產生的備份檔名，讓 diff 更乾淨
mv ${pveManagerLib_JS}.diff.tmp ${pveManagerLib_JS}.diff

# Output the diff files
echo "Diff for $NODES_PM:"
cat ${NODES_PM}.diff

echo "Diff for $pveManagerLib_JS:"
cat ${pveManagerLib_JS}.diff