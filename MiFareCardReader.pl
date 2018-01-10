#
# 1. Clear console
# 2. Detect USB devices
# 3. Select USB device to open
# 4. Initialise device and set correct baud and settings
# 5. Read the device and print card info

# Harry Podciborski 15/01/2015
# Version 1.0
# For Windows.. 


use Win32::Console;								
$OUT = Win32::Console->new(STD_OUTPUT_HANDLE);
$OUT->Cls;
$|=1;
$comPort = "COM3";		

print "
***************************************** 
############ USB Card Reader ############                         
*****************************************\n\n";

## check ports that coudl be used

use Win32::SerialPort;
use Win32::Clipboard;
$CLIP = Win32::Clipboard();

my $config_file = 'thermo.cfg';
my $PortObj = new Win32::SerialPort($comPort) || die "Unable to open COM port";
 $PortObj->databits(8);
 $PortObj->baudrate(38400);
 $PortObj->parity("none");
 $PortObj->stopbits(1);
 $PortObj->handshake("rts");
 $PortObj->buffers(4096, 4096);
 $PortObj->write_settings || undef $PortObj;
 $PortObj->save($config_file);

$PortObj->close();

print "Connected.. awaiting card\n\n";

my $status = pack( 'C*', '0x02,0xFF,0x69,0x96,0x03' );

while(1) {
    my $port = new Win32::SerialPort($comPort, $config_file) || die "Unable to open: $^E\n";
    my $status = pack('HHHHHH', '02', 'FF', '69', '96', '03');

    $port->write($status);
    sleep 1;
    my $result = $port->input;		## GET Card UUID
    print "result = $result\n";

    $port->close || warn "Close Failed!\n";
    undef $port;
    sleep 1;
}