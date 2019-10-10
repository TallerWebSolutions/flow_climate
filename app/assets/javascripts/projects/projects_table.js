function projectsTableTabBehaviour() {
    $("#projects-list-tab").addClass("active");
    $("#projects-list").show();

    const ganttDiv = $('#projects-gantt-div');
    buildGanttChart(ganttDiv);
}
