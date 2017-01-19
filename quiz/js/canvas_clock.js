//
/*時計を表示する*/
function clock(id, time, options){
  var canvas = document.getElementById(id);
  if ( ! canvas || ! canvas.getContext ) { return; }
  
  var size = (options && options['size']) ? options['size'] : 200;
  var radius = (options && options['radius']) ? options['radius'] : (0.95 * 0.5 * size);
  var fontSize = (options && options['fontSize']) ? options['fontSize'] : 15;
  var displaySecond = (options && options['displaySecond']) ? options['displaySecond'] : false;
  
  canvas.setAttribute('width', size);
  canvas.setAttribute('height', size);
  var centerX = size * 0.5
  var centerY = size * 0.5
  
  var ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  {//時計（丸枠と文字）
    ctx.beginPath();
    ctx.lineWidth = 1.0;
    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false);
    ctx.stroke(); //

    ctx.beginPath();
    ctx.textAlign = 'center';
    ctx.textBaseLine = 'middle';
    ctx.font = String(fontSize) + "px 'Times New Roman'";
      
    (Array.apply(null, {length: 12})).forEach(function(_, index, array){
      var d = index * 30;
      var theta = Math.PI * ((90 - d) / 180);
      var x = centerX + 0.9 * (radius * Math.cos(theta));
      var y = centerY - 0.9 * (radius * Math.sin(theta));
      var hour = (index == 0 ? 12 : index);
        
      ctx.fillText(hour, x, y + (fontSize / 3.0));
    });
  }
  
  //針を描画する
  function drawHand(theta, lineWidth, lengthRatio){
    ctx.beginPath();
    ctx.lineWidth = lineWidth;
    ctx.moveTo(centerX, centerY);
    ctx.lineTo(centerX + (lengthRatio * radius * Math.cos(theta)), centerX - (lengthRatio * radius * Math.sin(theta)));
    ctx.stroke();
  };
  
  var dt = new Date('2017-01-01T' + time + 'Z');
  { //長針
    var totalSeconds = ((dt.getUTCHours() * 60) + dt.getMinutes()) * 60 + dt.getSeconds();
    var hoursTheta = (Math.PI * 0.5) - ((4 * Math.PI) * totalSeconds /(24 * 60 * 60));
    drawHand(hoursTheta, 3.0, 0.6);
  }
  { //短針
    var seconds = (dt.getMinutes() * 60) + dt.getSeconds();
    var minutesTheta = (Math.PI * 0.5) - ((2 * Math.PI) * seconds / (60 * 60));
    drawHand(minutesTheta, 2.0, 0.8);
  }
  if(displaySecond){ //秒針
    var secondsTheta = (Math.PI * 0.5) - ((2 * Math.PI) * dt.getSeconds() / 60);
    drawHand(secondsTheta, 1.0, 0.7);
  }
}
/*現在時刻の時計を表示する*/
function currentClock(id, options){
  function zeroPad(n){
    return ('00' + n).slice(-2);
  }
  var now = new Date();
  var t = zeroPad(now.getHours()) + ':' + zeroPad(now.getMinutes()) + ':' + zeroPad(now.getSeconds());
  clock(id, t, options);
}

