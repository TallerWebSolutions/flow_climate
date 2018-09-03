function initializeTimeline() {
    const arrayOfDates = JSON.parse($('#array_of_dates_').val());

    const eventsDates = [new Date(arrayOfDates[0].date.replace(/-/g, '\/')), new Date(arrayOfDates[1].date.replace(/-/g, '\/')), new Date(arrayOfDates[2].date.replace(/-/g, '\/')), new Date(arrayOfDates[3].date.replace(/-/g, '\/'))];

    const earliestDate = new Date(Math.min.apply(null, eventsDates));
    const latestDate = new Date(Math.max.apply(null, eventsDates));

    const oneDay = 1000 * 60 * 60 * 24;

    const diffOfDays = Math.ceil((latestDate.getTime() - earliestDate.getTime()) / (oneDay));

    for (let i = 0; i <= diffOfDays + 1; i++) {
        const matchingDateInTimeline = arrayOfDates.find(item => new Date(item.date.replace(/-/g, '\/')).getTime() === earliestDate.getTime());
        if (matchingDateInTimeline !== undefined) {
            $("#timeline").append("<div class='timeline-day' style='background-color: " + matchingDateInTimeline.color + "'>" + earliestDate.getDate() + "/" + (earliestDate.getMonth() + 1) + "</div>");
        } else {
            $("#timeline").append("<div class='timeline-day'>" + earliestDate.getDate() + "/" + (earliestDate.getMonth() + 1) + "</div>");
        }
        earliestDate.setDate(earliestDate.getDate() + 1);
    }
}

$(document).ready(function() {
    initializeTimeline();
});
