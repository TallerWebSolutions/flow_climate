$(document).ready(function() {
    const queueElement = document.getElementById('queue-bar');
    const maxQueueValue = $("#queue_percentage").val();
    runProgressBar(queueElement, maxQueueValue);

    const streamElement = document.getElementById('queue-bar');
    const maxStreamValue = $("#upstream_percentage").val();
    runProgressBar(streamElement, maxStreamValue);
});

function runProgressBar(element, maxValue) {
    let width = 0;
    const id = setInterval(frame, 10);

    function frame() {
        if (width >= maxValue) {
            clearInterval(id);
        } else {
            width++;
            element.style.width = `${width}%`;
        }
    }
}
