//////////////////////////////////////
// Globals
//////////////////////////////////////

var chromaOrange = new chroma.scale(['#00ff00', '#e0e000', '#ff7f00', '#b60101']);
var context = new webkitAudioContext();
var micRunning  = false;
var isRecording = false;
var width  = 0;
var height = 0;

var scriptProcessor = context.createScriptProcessor(2048, 1, 1);
scriptProcessor.connect(context.destination);

var analyser = context.createAnalyser();
analyser.smoothingTimeConstant = 0;
analyser.fftSize = 512;
analyser.connect(scriptProcessor);

//////////////////////////////////////
// Functions
//////////////////////////////////////

scriptProcessor.onaudioprocess = function () {
  var array = new Uint8Array(analyser.frequencyBinCount);
  analyser.getByteTimeDomainData(array);

  if(micRunning) {
    drawLiveWaveform(array);
  }

  if(isRecording) {
    drawRecording(array);
  }
}

function setupCanvases() {
  width = $('#canvases').width();
  height = $('#canvases').height();

  $('#grid, #recording, #cursor').each(function(){
    ctx = $(this)[0].getContext('2d');
    ctx.canvas.width = width;
    ctx.canvas.height = height;
  });
}

function drawGrid() {
  ctx = $("#grid")[0].getContext('2d');

  // draw the grid
  for(var i=0; i < width;i++) {
    if(i%100==0 && i!=0 && i!=width) {
      // every 100 pixels...
      ctx.fillStyle = "#333333";
      ctx.fillRect(i, 0, 1, height);
    }
  }
}

function drawLiveWaveform(array) {
  var ctx = $("#live-waveform").get()[0].getContext("2d");
  ctx.clearRect(0, 0, 100, 35);
  for ( var i = 0; i < (array.length); i++ ){
    var value = array[i];
    ctx.fillStyle = chromaOrange(value/255).hex();
    ctx.fillRect((i*100)/255,(value/2)-45,1,1);
  }
}

function drawWaveform(array) {
  var ctx = $("#recording").get()[0].getContext("2d");

  var waveValues = [];
  var min = Math.min.apply(Math, array)*400/255;
  var max = Math.max.apply(Math, array)*400/255;
  for(min; min < max; min++) { waveValues.push(min); }

  for (var i = 0; i < waveValues.length; i++) {
    var value = waveValues[i];
    ctx.fillStyle = chromaOrange(value/400).hex();
    ctx.fillRect(0, value, 1, 1);
  }
  ctx.translate(1, 0);
}

function drawCursor() {
  var ctx = $("#cursor").get()[0].getContext("2d");
  ctx.fillStyle = 'rgba(255,255,255,0.1)';
  ctx.fillRect(0,0,1,height);
  ctx.translate(1, 0);
}

function drawRecording(array) {
  drawWaveform(array);
  drawCursor();
}

//////////////////////////////////////
// On-Ready
//////////////////////////////////////

$(document).ready(function(){

  // microphone start
  $("#mic-start").click(function(){
    console.log("clicked mic start");
    navigator.webkitGetUserMedia({audio:true},function(stream) {
      micSource = context.createMediaStreamSource(stream);
      micSource.connect(analyser);
      micRunning = true;
      $('.navbar .record').removeClass('disabled');
    });
  });

  // microphone stop
  $("#mic-stop").click(function(){
    micSource.disconnect(analyser);
    micRunning = false;
    $("#live-waveform").get()[0].getContext("2d").clearRect(0, 0, 100, 35);
    $('.navbar .record').addClass('disabled');
  });

  // recording start
  $('#rec-start').click(function(){
    if(!$(this).closest('div.record').hasClass('disabled')) {
      $('div.record i').addClass('active');
      isRecording = true;
    }
  });

  // recording stop
  $('#rec-stop').click(function(){
    $('div.record i').removeClass('active');
    isRecording = false;
  });

  setupCanvases();
  drawGrid();
});
