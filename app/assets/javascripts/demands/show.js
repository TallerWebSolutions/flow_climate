$(document).ready(function() {
    var queueElement = document.getElementById("queue-bar");
    var maxQueueValue = $("#queue_percentage").val();
    runProgressBar(queueElement, maxQueueValue);

    var streamElement = document.getElementById("queue-bar");
    var maxStreamValue = $("#upstream_percentage").val();
    runProgressBar(streamElement, maxStreamValue);
});

function runProgressBar(element, maxValue) {
    var width = 0;
    var id = setInterval(frame, 10);

    function frame() {
        if (width >= maxValue) {
            clearInterval(id);
        } else {
            width++;
            element.style.width = width + '%';
        }
    }
}
