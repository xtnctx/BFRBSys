

// Data
var line1 = new TimeSeries();
var line2 = new TimeSeries();
var line3 = new TimeSeries();

// Add a random value to each line every second
setInterval(function() {
    line1.append(new Date().getTime(), Math.random());
    line2.append(new Date().getTime(), Math.random());
    line3.append(new Date().getTime(), Math.random());
}, 200);



var smoothie = new SmoothieChart({
    grid: { strokeStyle:'rgb(125, 0, 0)', fillStyle:'rgb(60, 0, 0)',
            lineWidth: 1, millisPerLine: 1000, verticalSections: 5, },
    labels: { fillStyle:'rgb(255, 255, 255)' },
    tooltip: true,
    millisPerPixel: 10, maxValue:1.5,minValue:-0.5
    });

// Add to SmoothieChart
smoothie.addTimeSeries(line1,
    { strokeStyle:'rgb(0, 255, 0)', fillStyle:'rgba(0, 255, 0, 0)', lineWidth: 1.3 });

smoothie.addTimeSeries(line2,
    { strokeStyle:'rgb(255, 0, 255)', fillStyle:'rgba(255, 0, 255, 0)', lineWidth: 1.3 });

smoothie.addTimeSeries(line3,
    { strokeStyle:'rgb(0, 0, 255)', fillStyle:'rgba(0, 0, 255, 0)', lineWidth: 1.3 });

smoothie.streamTo(document.getElementById("mycanvas"), 200);