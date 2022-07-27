const SERVICE_UUID = 'bf88b656-0000-4a61-86e0-769c741026c0';
const FILE_BLOCK_UUID = 'bf88b656-3000-4a61-86e0-769c741026c0';
const FILE_LENGTH_UUID = 'bf88b656-3001-4a61-86e0-769c741026c0';
const FILE_MAXIMUM_LENGTH_UUID = 'bf88b656-3002-4a61-86e0-769c741026c0';
const FILE_CHECKSUM_UUID = 'bf88b656-3003-4a61-86e0-769c741026c0';
const COMMAND_UUID = 'bf88b656-3004-4a61-86e0-769c741026c0';
const TRANSFER_STATUS_UUID = 'bf88b656-3005-4a61-86e0-769c741026c0';
const ERROR_MESSAGE_UUID = 'bf88b656-3006-4a61-86e0-769c741026c0';

const ACC_DATA_UUID = 'bf88b656-3007-4a61-86e0-769c741026c0';
const GYRO_DATA_UUID = 'bf88b656-3008-4a61-86e0-769c741026c0';
const DIST_DATA_UUID = 'bf88b656-3009-4a61-86e0-769c741026c0';
     
const connectButton = document.getElementById('connect-button');
const transferFileButton = document.getElementById('transfer-file-button');
const cancelTransferButton = document.getElementById('cancel-transfer-button');
const statusElement = document.getElementById('status-label');
const dstData = document.getElementById('dstData');

//  ################### Data to be sent ###################

const contentString = '28';

// #########################################################


// Check that the browser supports WebBLE, and raise a warning if not.
if (!("bluetooth" in navigator)) {
  msg('Browser not supported');
  alert('Error: This browser doesn\'t support Web Bluetooth. Try using Chrome.');
}

// This is a simple demonstration of how to use WebBLE to transfer tens of kilobytes
// of data to an Arduino Nano BLE board with the corresponding sketch installed.
//
// The basic API is that you call connect() to prompt the user to pair with the board,
// then transferFile() with the data you want to send. If it completes successfully
// then onTransferSuccess() will be called, otherwise onTransferError() will be
// invoked. Progress information is reported by the msg() function, and there's a
// human-readable explanation of any error in onErrorMessageChanged().
//
// The file transfer process is verified using a CRC32 checksum, which you can also
// choose to read before sending a file if you want to tell if it's already been sent.



connectButton.addEventListener('click', async function(event) {
  connect();
  transferFileButton.addEventListener('click', function(event) {
    msg('Trying to write file ...');
    // You'll want to replace this with the data you want to transfer.
    let fileContents = prepareDummyFileContents(contentString.length);
    transferFile(fileContents);
  });
  cancelTransferButton.addEventListener('click', function(event) {
    msg('Trying to cancel transfer ...');
    cancelTransfer();
  });

});

// ------------------------------------------------------------------------------
// This section contains functions you may want to customize for your own page.
     
// You'll want to replace these two functions with your own logic, to take what
// actions your application needs when a file transfer succeeds, or errors out.
async function onTransferSuccess() {
  isFileTransferInProgress = false;
  let checksumValue = await fileChecksumCharacteristic.readValue();
  let checksumArray = new Uint32Array(checksumValue.buffer);
  let checksum = checksumArray[0];
  msg('File transfer succeeded: Checksum 0x' + checksum.toString(16));
}

// Called when something has gone wrong with a file transfer.
function onTransferError() {
  isFileTransferInProgress = false;
  msg("File transfer error");  
}

// Called when an error message is received from the device. This describes what
// went wrong with the transfer in a user-readable form.
function onErrorMessageChanged(event) {
  let value = new Uint8Array(event.target.value.buffer);
  let utf8Decoder = new TextDecoder();
  let errorMessage = utf8Decoder.decode(value);
  console.log("Error message = " + errorMessage);
}

// Display logging information in the interface, you'll want to customize this
// for your page.
function msg(m){
  statusElement.innerHTML = m;
}


// ------------------------------------------------------------------------------
// This section has the public APIs for the transfer process, which you
// shouldn't need to modify but will have to call.
          
async function connect() {
  msg('Requesting device ...');

  const device = await navigator.bluetooth.requestDevice({
    filters: [{services: [SERVICE_UUID]}]
  });

  msg('Connecting to device ...');
  function onDisconnected(event) {
    msg('Device ' + device.name + ' is disconnected.');
  }
  device.addEventListener('gattserverdisconnected', onDisconnected);
  const server = await device.gatt.connect();

  msg('Getting primary service ...');
  const service = await server.getPrimaryService(SERVICE_UUID);
  
  msg('Getting characteristics ...');
  fileBlockCharacteristic = await service.getCharacteristic(FILE_BLOCK_UUID);
  fileLengthCharacteristic = await service.getCharacteristic(FILE_LENGTH_UUID);
  fileMaximumLengthCharacteristic = await service.getCharacteristic(FILE_MAXIMUM_LENGTH_UUID);
  fileChecksumCharacteristic = await service.getCharacteristic(FILE_CHECKSUM_UUID);
  commandCharacteristic = await service.getCharacteristic(COMMAND_UUID);

  transferStatusCharacteristic = await service.getCharacteristic(TRANSFER_STATUS_UUID);
  await transferStatusCharacteristic.startNotifications();
  transferStatusCharacteristic.addEventListener('characteristicvaluechanged', onTransferStatusChanged);

  errorMessageCharacteristic = await service.getCharacteristic(ERROR_MESSAGE_UUID);
  await errorMessageCharacteristic.startNotifications();
  errorMessageCharacteristic.addEventListener('characteristicvaluechanged', onErrorMessageChanged);

  accDataCharacteristic = await service.getCharacteristic(ACC_DATA_UUID);
  await accDataCharacteristic.startNotifications();
  accDataCharacteristic.addEventListener('characteristicvaluechanged', onAccChanged);

  gyroDataCharacteristic = await service.getCharacteristic(GYRO_DATA_UUID);
  await gyroDataCharacteristic.startNotifications();
  gyroDataCharacteristic.addEventListener('characteristicvaluechanged', onGyroChanged);

  distDataCharacteristic = await service.getCharacteristic(DIST_DATA_UUID);
  await distDataCharacteristic.startNotifications();
  distDataCharacteristic.addEventListener('characteristicvaluechanged', onDistChanged);

  isFileTransferInProgress = false;
  
  msg('Connected to device');
}



async function myValue() {
  let readValue = await serialDataCharacteristic.readValue()
  let readValueArray = new Uint32Array(readValue.buffer);
  let value = readValueArray[0];
  // return value
}

async function transferFile(fileContents) {
  let maximumLengthValue = await fileMaximumLengthCharacteristic.readValue();
  let maximumLengthArray = new Uint32Array(maximumLengthValue.buffer);
  let maximumLength = maximumLengthArray[0];
  if (fileContents.byteLength > maximumLength) {
    msg("File length is too long: " + fileContents.byteLength + " bytes but maximum is " + maximumLength);
    return;
  }
  
  if (isFileTransferInProgress) {
    msg("Another file transfer is already in progress");
    return;
  }
  
  let fileLengthArray = Int32Array.of(fileContents.byteLength);
  await fileLengthCharacteristic.writeValue(fileLengthArray);
  let fileChecksum = crc32(fileContents);
  let fileChecksumArray = Uint32Array.of(fileChecksum);
  await fileChecksumCharacteristic.writeValue(fileChecksumArray);
  
  let commandArray = Int32Array.of(1);
  await commandCharacteristic.writeValue(commandArray);
    
  sendFileBlock(fileContents, 0);
}
     
async function cancelTransfer() {  
  let commandArray = Int32Array.of(2);
  await commandCharacteristic.writeValue(commandArray);
} 

// ------------------------------------------------------------------------------
// The rest of these functions are internal implementation details, and shouldn't
// be called by users of this module.
     
function onTransferInProgress() {
  isFileTransferInProgress = true; 
}
   
function onTransferStatusChanged(event) {
  let value = new Uint32Array(event.target.value.buffer);
  let statusCode = value[0];
  if (statusCode === 0) {
    onTransferSuccess();
  } else  if (statusCode === 1) {
    onTransferError();
  } else if (statusCode === 2) {
    onTransferInProgress(); 
  }
}


function prepareDummyFileContents(fileLength) {
  let result = new ArrayBuffer(fileLength);
  let bytes = new Uint8Array(result);
  for (var i = 0; i < bytes.length; ++i) {
    var contentIndex = (i % contentString.length);
    bytes[i] = contentString.charCodeAt(contentIndex);
  }
  return result;
}
     
// See http://home.thep.lu.se/~bjorn/crc/ for more information on simple CRC32 calculations.
function crc32ForByte(r) {
  for (let j = 0; j < 8; ++j) {
    r = (r & 1? 0: 0xedb88320) ^ r >>> 1;
  }
  return r ^ 0xff000000;
}

function crc32(dataIterable) {
  const tableSize = 256;
  if (!window.crc32Table) {
    crc32Table = new Uint32Array(tableSize);
    for(let i = 0; i < tableSize; ++i) {
      crc32Table[i] = crc32ForByte(i);
    }
    window.crc32Table = crc32Table;
  }
  let dataBytes = new Uint8Array(dataIterable);
  let crc = 0;
  for(let i = 0; i < dataBytes.byteLength; ++i) {
    const crcLowByte = (crc & 0x000000ff);
    const dataByte = dataBytes[i];
    const tableIndex = crcLowByte ^ dataByte;
    // The last >>> is to convert this into an unsigned 32-bit integer.
    crc = (window.crc32Table[tableIndex] ^ (crc >>> 8)) >>> 0;
  }
  return crc;
}

// This is a small test function for the CRC32 implementation, not normally called but left in
// for debugging purposes. We know the expected CRC32 of [97, 98, 99, 100, 101] is 2240272485,
// or 0x8587d865, so if anything else is output we know there's an error in the implementation.
function testCrc32() {
  const testArray = [97, 98, 99, 100, 101];
  const testArrayCrc32 = crc32(testArray);
  console.log('CRC32 for [97, 98, 99, 100, 101] is 0x' + testArrayCrc32.toString(16) + ' (' + testArrayCrc32 + ')');
}

async function sendFileBlock(fileContents, bytesAlreadySent) {
  let bytesRemaining = fileContents.byteLength - bytesAlreadySent;
  
  const maxBlockLength = 128;
  const blockLength = Math.min(bytesRemaining, maxBlockLength);
  var blockView = new Uint8Array(fileContents, bytesAlreadySent, blockLength);
  fileBlockCharacteristic.writeValue(blockView)
  .then(_ => {
    bytesRemaining -= blockLength;
    if ((bytesRemaining > 0) && isFileTransferInProgress) {
      msg('File block written - ' + bytesRemaining +' bytes remaining');
      bytesAlreadySent += blockLength;
      sendFileBlock(fileContents, bytesAlreadySent);
    }
  })
  .catch(error => {
    console.log(error);
    msg('File block write error with ' + bytesRemaining + ' bytes remaining, see console');
  });
}

 
const rawData = []; // ax,ay,az, gx,gy,gz, temp, dist







/* Live plot */

// Data
var aX = new TimeSeries();
var aY = new TimeSeries();
var aZ = new TimeSeries();

var gX = new TimeSeries();
var gY = new TimeSeries();
var gZ = new TimeSeries();

function dataPush() {
  let ax = aX.data.slice(-1)[0][1];
  let ay = aY.data.slice(-1)[0][1];
  let az = aZ.data.slice(-1)[0][1];

  let gx = gX.data.slice(-1)[0][1];
  let gy = gY.data.slice(-1)[0][1];
  let gz = gZ.data.slice(-1)[0][1];

  rawData.push([ax, ay, az, gx, gy, gz])
}

function captureData() {  
  const samples = 10;

  for(let i = 0; i < samples; ++i) {
    (function(i) {
      setTimeout(() => {
        dataPush()
        console.log(i);

        if(i+1 === samples){
          console.log('done');
          let csvContent = rawData.map(e => e.join(",")).join(";");
          const dataField = document.getElementById('data-field');
          dataField.value = csvContent
        }
        
      }, 1000 * i);
    })(i);
  }
}

/* JQuery - AJAX */
// Prevents page reload when submitting form
$(document).on('submit', '#data-form', function(e) {
  e.preventDefault();
  
  $.ajax({
    type: 'POST',
    url: 'export/',
    data: {
      data: $('#data-field').val(),
      csrfmiddlewaretoken: $('input[name=csrfmiddlewaretoken]').val()
    },

    success: function() {

    }
  })
})



/* Parse the received data */
function ab2str(buf) {
    return String.fromCharCode(...buf);
}

function onDistChanged(event) {
  let distValue = new Uint8Array(event.target.value.buffer);
  dstData.innerHTML = distValue[0];
}


function onAccChanged(event) {
    let avalue = new Uint8Array(event.target.value.buffer);
    let adata = ab2str(avalue);
    const adataArr = adata.split(",");

    aX.append(new Date().getTime(), adataArr[0]);
    aY.append(new Date().getTime(), adataArr[1]);
    aZ.append(new Date().getTime(), adataArr[2]);
}

function onGyroChanged(event) {
    let gvalue = new Uint8Array(event.target.value.buffer);
    let gdata = ab2str(gvalue);
    const gdataArr = gdata.split(",");

    gX.append(new Date().getTime(), gdataArr[0]);
    gY.append(new Date().getTime(), gdataArr[1]);
    gZ.append(new Date().getTime(), gdataArr[2]);
}

/* Accelerometer Canvas */
var accSmoothie = new SmoothieChart({
    grid: { strokeStyle:'rgb(125, 0, 0)', fillStyle:'rgb(60, 0, 0)',
            lineWidth: 1, millisPerLine: 1000, verticalSections: 5, },
    labels: { fillStyle:'rgb(255, 255, 255)' },
    tooltip: true,
    millisPerPixel: 10, maxValue:2.5,minValue:-2.5
    });

// Add to SmoothieChart
accSmoothie.addTimeSeries(aX,
    { strokeStyle:'rgb(0, 255, 0)', fillStyle:'rgba(0, 255, 0, 0)', lineWidth: 1.3 });

accSmoothie.addTimeSeries(aY,
    { strokeStyle:'rgb(255, 0, 255)', fillStyle:'rgba(255, 0, 255, 0)', lineWidth: 1.3 });

accSmoothie.addTimeSeries(aZ,
    { strokeStyle:'rgb(0, 0, 255)', fillStyle:'rgba(0, 0, 255, 0)', lineWidth: 1.3 });

accSmoothie.streamTo(document.getElementById("accelerometerCanvas"), 200);






/* Gyroscope Canvas */
var gyroSmoothie = new SmoothieChart({
    grid: { strokeStyle:'rgb(125, 0, 0)', fillStyle:'rgb(60, 0, 0)',
            lineWidth: 1, millisPerLine: 1000, verticalSections: 5, },
    labels: { fillStyle:'rgb(255, 255, 255)' },
    tooltip: true,
    millisPerPixel: 10, maxValue:800,minValue:-800
    });

// Add to SmoothieChart
gyroSmoothie.addTimeSeries(gX,
    { strokeStyle:'rgb(0, 255, 0)', fillStyle:'rgba(0, 255, 0, 0)', lineWidth: 1.3 });

gyroSmoothie.addTimeSeries(gY,
    { strokeStyle:'rgb(255, 0, 255)', fillStyle:'rgba(255, 0, 255, 0)', lineWidth: 1.3 });

gyroSmoothie.addTimeSeries(gZ,
    { strokeStyle:'rgb(0, 0, 255)', fillStyle:'rgba(0, 0, 255, 0)', lineWidth: 1.3 });

gyroSmoothie.streamTo(document.getElementById("gyroscopeCanvas"), 200);
