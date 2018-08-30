function buildStatusReportProjectionCharts() {
    var statusReportDatesOddsDiv = $('#status-report-dates-odds-column');
    buildColumnChart(statusReportDatesOddsDiv);
}

function GetEvents() {
    return [
        {
            id: 1,
            title: "Catalyst 0",
            startDate: "2017-9-17",
            endDate: "2017-9-17",
            notes: "This is the last catalyst we shall be tracking in the year 2017. There are no interesting events occurring after this one."
        },
        {
            id: 2,
            title: "Catalyst 1",
            startDate: "2018-1-18",
            endDate: "2018-1-18",
            notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        },
        {
            id: 3,
            title: "Catalyst A",
            startDate: "2018-1-23",
            endDate: "2018-1-23",
            notes: "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        },
        {
            id: 4,
            title: "Catalyst 2",
            startDate: "2018-3-7",
            endDate: "2018-3-9",
            notes: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo."
        },
        {
            id: 5,
            title: "Catalyst 3",
            startDate: "2018-3-28"
        },
        {
            id: 6,
            title: "Catalyst 4",
            startDate: "2018-10-13"
        },
        {
            id: 7,
            title: "Catalyst B",
            startDate: "2018-11-12"
        },
        {
            id: 8,
            title: "Catalyst 5",
            startDate: "2019-3-2"
        },
        {
            id: 9,
            title: "Catalyst C",
            startDate: "2019-10-2"
        }
    ]
}
;
