#!/bin/bash
name="vsim-netapp-DOT9.7-cm_nodar"
memory=6192
IDE00="vsim-NetAppDOT-simulate-disk1.vmdk"
IDE01="vsim-NetAppDOT-simulate-disk2.vmdk"
IDE10="vsim-NetAppDOT-simulate-disk3.vmdk"
IDE11="vsim-NetAppDOT-simulate-disk4.vmdk"

#need to make sure virtualbox is installed
if [ -z "$(which vboxmanage)" ];then echo "vboxmanage not found";exit;fi

# Extract the OVA archive
tar -xzvf "$name".ova

#Make a new VM from scratch
vboxmanage createvm --name "$name" --ostype "FreeBSD_64" --register
vboxmanage modifyvm "$name" --ioapic on 
vboxmanage modifyvm "$name" --vram 16
vboxmanage modifyvm "$name" --cpus 2
vboxmanage modifyvm "$name" --memory "$memory"

# Add Network Adapters
vboxmanage modifyvm "$name" --nic1 intnet --nictype1 82545EM --cableconnected1 on
vboxmanage modifyvm "$name" --nic2 intnet --nictype2 82545EM --cableconnected2 on
vboxmanage modifyvm "$name" --nic3 intnet --nictype3 82545EM --cableconnected3 on
vboxmanage modifyvm "$name" --nic4 intnet --nictype4 82545EM --cableconnected4 on

# Add serial ports
vboxmanage modifyvm "$name" --uart1 0x3F8 4
vboxmanage modifyvm "$name" --uart2 0x2F8 3

# Add a blank floppy
vboxmanage storagectl "$name" --name floppy --add floppy --controller I82078 --portcount 1 
vboxmanage storageattach "$name" --storagectl floppy --device 0 --medium emptydrive

# Add an IDE controller
vboxmanage storagectl "$name" --name IDE    --add ide    --controller PIIX4  --portcount 2

# Attach VMDKs
vboxmanage storageattach "$name" --storagectl IDE --port 0 --device 0 --type hdd --medium "$IDE00"
vboxmanage storageattach "$name" --storagectl IDE --port 0 --device 1 --type hdd --medium "$IDE01"
vboxmanage storageattach "$name" --storagectl IDE --port 1 --device 0 --type hdd --medium "$IDE10"
vboxmanage storageattach "$name" --storagectl IDE --port 1 --device 1 --type hdd --medium "$IDE11"

# Export the finished VM to a new OVA file
vboxmanage export "$name" -o "$name"-vbox.ova

# cleanup
vboxmanage unregistervm "$name" --delete

