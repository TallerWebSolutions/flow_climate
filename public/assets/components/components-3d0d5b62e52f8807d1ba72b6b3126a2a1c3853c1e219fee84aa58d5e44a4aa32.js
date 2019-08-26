function accordionBehaviour() {
    const acc = document.getElementsByClassName("accordion");
    let i;

    for (i = 0; i < acc.length; i++) {
        acc[i].addEventListener("click", function() {
            this.classList.toggle("active");
            const panel = this.nextElementSibling;
            if (panel.style.display === "block") {
                panel.style.display = "none";
            } else {
                panel.style.display = "block";
            }
        });
    }
}

function openTab(evt, tabName, tabClass, tabContentName) {
    let i, tabcontent, subTabs;
    tabcontent = document.getElementsByClassName(tabContentName);
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }

    subTabs = document.getElementsByClassName(tabClass);
    for (i = 0; i < subTabs.length; i++) {
        subTabs[i].className = subTabs[i].className.replace(" active", "");
    }
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.className += " active";
}

function openDemandsDiv(evt, divId, inactiveDivId) {
    let i, listingTabs;
    listingTabs = document.getElementsByClassName("listing-tab");
    for (i = 0; i < listingTabs.length; i++) {
        listingTabs[i].className = listingTabs[i].className.replace(" btn-active", "");
    }

    document.getElementById(divId).style.display = "block";
    document.getElementById(inactiveDivId).style.display = "none";

    evt.currentTarget.className += " btn-active";
}

function toggleTableDetails(componentId) {
    $(`#${componentId}`).toggle();
    $('.toggle-table-details').blur();
}


function hideAllComponents(navItem) {
    $('.tab-container').hide();
    navItem.removeClass('active');
}

;
