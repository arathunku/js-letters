canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d"),
    painting = false,
    lastX = 0,
    lastY = 0,
    lineThickness = 1,
    dim = 100;
canvas.width = canvas.height = dim;
ctx.fillRect(0, 0, dim, dim);

canvas.onmousedown = function(e) {
    painting = true;
    ctx.fillStyle = "#ffffff";
    lastX = e.pageX - this.offsetLeft;
    lastY = e.pageY - this.offsetTop;
};

canvas.onmouseup = function(e){
    painting = false;
    Learn.clean();
};

canvas.onmousemove = function(e) {
    if (painting) {
        mouseX = e.pageX - this.offsetLeft;
        mouseY = e.pageY - this.offsetTop;

        // find all points between
        var x1 = mouseX,
            x2 = lastX,
            y1 = mouseY,
            y2 = lastY;


        var steep = (Math.abs(y2 - y1) > Math.abs(x2 - x1));
        if (steep){
            var x = x1;
            x1 = y1;
            y1 = x;

            var y = y2;
            y2 = x2;
            x2 = y;
        }
        if (x1 > x2) {
            var x = x1;
            x1 = x2;
            x2 = x;

            var y = y1;
            y1 = y2;
            y2 = y;
        }

        var dx = x2 - x1,
            dy = Math.abs(y2 - y1),
            error = 0,
            de = dy / dx,
            yStep = -1,
            y = y1;

        if (y1 < y2) {
            yStep = 1;
        }

        lineThickness = 3 - Math.sqrt((x2 - x1) *(x2-x1) + (y2 - y1) * (y2-y1))/10;
        if(lineThickness < 1){
            lineThickness = 1;
        }

        for (var x = x1; x < x2; x++) {
            if (steep) {
                ctx.fillRect(y, x, lineThickness , lineThickness );
            } else {
                ctx.fillRect(x, y, lineThickness , lineThickness );
            }

            error += de;
            if (error >= 0.5) {
                y += yStep;
                error -= 1.0;
            }
        }



        lastX = mouseX;
        lastY = mouseY;

    }
}

canvas.getMatrix = function(){
    var map = [],
        data = ctx.getImageData(0,0, dim, dim).data;

    for (var i = 0; i < data.length; i += 4) {
         var red = data[i],
             green = data[i + 1],
             blue = data[i + 2],
             hex = red + green + blue;

         if (hex > 255 ) {
            map.push(1);
         } else {
            map.push(0);
        }
    }
    var new_matrix = []
    for (var i = 0; i < dim; i += 1) {
        var tmp = []
        for (var j = 0; j < dim; j += 1) {
            tmp.push(map[i*dim+j]);
        }
        new_matrix.push(tmp);
    }

    return math.matrix(new_matrix);
};

canvas.showMatrix = function(matrix) {
    if(!matrix) {
        matrix = canvas.getMatrix();
    }

    var text = [];
    for (var i = 0; i < dim; i += 1) {
        text.push('[')
        for (var j = 0; j < dim; j += 1) {
            text.push(matrix[i*dim+j]);
            if(j < dim-1)
                text.push(',');
        }
        if(i < dim-1)
            text.push('],<br>');
        else
            text.push(']<br>');
    }
    text = text.join('');
    document.querySelector('.showMatrix').innerHTML = text;
    return text;
};

canvas.clean = function(){
    ctx.fillStyle="#000000";
    ctx.fillRect(0,0,dim,dim);
    Learn.clean();
};

window.canvas = canvas;


var matrices = [];
next = function(){
    matrices.push(canvas.getMatrix());
    canvas.clean();
};

showAll = function(){
    var text = [];
    text.push('[<br>');
    for (var i = 0; i < matrices.length; i += 1) {
        text.push('[<br>');
        text.push(canvas.showMatrix(matrices[i]));
        if(i < matrices.length-1)
            text.push('],<br>');
        else
            text.push(']<br>');
    }
    text.push(']<br>');
    document.querySelector('.showMatrix').innerHTML = text.join('');
};
