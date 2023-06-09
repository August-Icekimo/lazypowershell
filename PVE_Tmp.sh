#!/bin/sh
# 修改pvemanagerlib.js使其顯示節點溫度
# 尚未完成
# Edit file 1 is $NODES_PM
export NODES_PM="/usr/share/perl5/PVE/API2/Nodes.pm"
# Edit file 2 is $pveManagerLib_JS
export pveManagerLib_JS="/usr/share/pve-manager/js/pvemanagerlib.js"

export ORG1='PVE::pvecfg::version_text();'
export ORG2='widget.pveNodeStatus'
export ORG3='pveversion',

# find $ORG is which line of $NODES.PM
# put shell "cat $NODES_PM | grep -n $ORG | cut -d: -f1" result into variable insertLine
insertLine=$(cat $NODES_PM | grep -n $ORG1 | cut -d: -f1)
 echo $insertLine

cat << N_PM >> $NODES_PM_ADD1
$res->{thermalstate} = `sensors`;
N_PM

# insert $NODES_PM_ADD1 after $insertLine
sed -i "${insertLine}r $NODES_PM_ADD1" $NODES_PM

cat << PMLIB_JS2 >> $pveManagerLib_JS_ADD2
            textField: 'pveversion',
            value: '',
        },
        {
            itemId: 'thermal',
            colspan: 2,
            printBar: false,
            title: gettext('Node Thermal State'),
            textField: 'thermalstate',
            renderer:function(value){
                const c0 = value.match(/Tctl.*?\+([\d\.]+)Â/)[1];
                const n0 = value.match(/Composite.*?\+([\d\.]+)Â/)[1];
                const n1 = value.match(/Sensor 2.*?\+([\d\.]+)Â/)[1];
                const g0 = value.match(/edge.*?\+([\d\.]+)Â/)[1];
                return `CPU: ${c0} ℃ SSD: ${n0} ℃ ${n1} ℃ GPU: ${g0} ℃ `
            }
PMLIB_JS2
# insert $pveManagerLib_JS_ADD2 after Line number $insertLine2
sed -i "${insertLine2}r $pveManagerLib_JS_ADD2" $pveManagerLib_JS

insertLine3=$(cat $pveManagerLib_JS | grep -n $ORG3 | cut -d: -f1)
echo $insertLine3

# 
# restart pveproxy service
echo "Restart PVE Proxy service"
sudo systemctl restart pveproxy