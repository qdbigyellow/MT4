$dest = "C:\Users\bigyellow\AppData\Roaming\MetaQuotes\Terminal\3212703ED955F10C7534BE8497B221F4\MQL4\Experts"

copy-item $PWD\Experts\*.ex4 $dest -force -recurse  -verbose
copy-item $PWD\Experts\*.mq4 $dest -force -recurse  -verbose
