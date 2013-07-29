
function drawGrid() {
  // first ensure the canvas is the right size
  width = $('#canvases').width();
  height = $('#canvases').height();

  gridCtx = $("#grid")[0].getContext('2d');
  gridCtx.canvas.width = width;
  gridCtx.canvas.height = height;

  // draw the grid
  gridCtx.fillStyle = "#00ff00";
  for(var i=0; i < width;i++) {
    if(i%100==0) {
      // every 100 pixels...
      gridCtx.fillStyle = "#333333";
      gridCtx.fillRect(i, 0, 1, height);
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

//////////////////////////////////////
// Globals
//////////////////////////////////////

var hot = new chroma.ColorScale({
    colors:['#000000', '#ff0000', '#ffff00', '#ffffff'],
    positions:[0, .25, .75, 1],
    mode:'rgb',
    limits:[0, 350]
});

var chromaOrange = new chroma.scale(['#ff0000', '#ffff00']);

var context = new webkitAudioContext();
var micRunning = false;

var scriptProcessor = context.createScriptProcessor(2048, 1, 1);
scriptProcessor.connect(context.destination);
scriptProcessor.onaudioprocess = function () {
  if (micRunning) {
    var array = new Uint8Array(analyser.frequencyBinCount);
    analyser.getByteTimeDomainData(array);
    drawLiveWaveform(array);
  }
}

var analyser = context.createAnalyser();
analyser.smoothingTimeConstant = 0;
analyser.fftSize = 512;
analyser.connect(scriptProcessor);

//////////////////////////////////////
// On-Ready
//////////////////////////////////////

$(document).ready(function(){

  // microphone start
  $("#mic-start").click(function () {
    console.log("clicked mic start");
    navigator.webkitGetUserMedia({audio:true},function(stream) {
      micSource = context.createMediaStreamSource(stream);
      micSource.connect(analyser);
      micRunning = true;
    });
  });

  // microphone stop
  $("#mic-stop").click(function () {
    micSource.disconnect(analyser);
    micRunning = false;
    $("#live-waveform").get()[0].getContext("2d").clearRect(0, 0, 100, 35);
  });

  drawGrid();
});
