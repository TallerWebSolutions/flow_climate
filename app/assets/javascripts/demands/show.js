$(document).ready(function() {
    const queueElement = document.getElementById('queue-bar');
    const maxQueueValue = $("#queue_percentage").val();
    runProgressBar(queueElement, maxQueueValue);

    const streamElement = document.getElementById('queue-bar');
    const maxStreamValue = $("#upstream_percentage").val();
    runProgressBar(streamElement, maxStreamValue);

    $('#demand-block-tab').addClass('active');
    $('#content-block').show();

    bindBlockFormModalAction();
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

let columnDemandShowLeadTimeBreakdownDiv = $('#demand-show-lead-time-breakdown-column');
if (columnDemandShowLeadTimeBreakdownDiv.length !== 0) {
    buildColumnChart(columnDemandShowLeadTimeBreakdownDiv);
}
