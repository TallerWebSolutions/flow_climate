import {normalizeTeamInfo} from "../Replenishment";

describe("pages/Replenishment", () => {
    describe("valid data from replenishings", () => {
        it("should normalize query results to the component shape", () => {
            const expected = {
                throughputData: [9, 2, 4, 6],
                averageThroughput: {
                    value: 5.25,
                    increased: false
                },
                leadTime: {
                    value: 26.73062348611111,
                    increased: true
                },
                workInProgress: 13
            }

            expect(normalizeTeamInfo(data)).toEqual(expected)
        })
    })
})

const data = {
    "team": {
        "id": "1",
        "name": "Vingadores",
        "throughputData": [
            9,
            2,
            4,
            6
        ],
        "averageThroughput": 5.25,
        "increasedAvgThroughtput": false,
        "leadTime": 26.73062348611111,
        "increasedLeadtime80": true,
        "workInProgress": 13,
        "lastReplenishingConsolidations": [
            {
                "__typename": "ReplenishingConsolidation",
                "id": "28231",
                "project": {
                    "__typename": "Project",
                    "id": "673",
                    "name": "Redesign - Informações de Venda",
                    "remainingWeeks": 2,
                    "remainingBacklog": 9,
                    "flowPressure": 2,
                    "flowPressurePercentage": 0,
                    "leadTimeP80": 4366647.3092,
                    "qtySelected": 0,
                    "qtyInProgress": 1,
                    "monteCarloP80": 41
                }
            },
            {
                "__typename": "ReplenishingConsolidation",
                "id": "28232",
                "project": {
                    "__typename": "Project",
                    "id": "689",
                    "name": "IstoÉ - Matéria Dinheiro e Editorias Rural",
                    "remainingWeeks": 5,
                    "remainingBacklog": 7,
                    "flowPressure": 0.25,
                    "flowPressurePercentage": 0,
                    "leadTimeP80": 0,
                    "qtySelected": 0,
                    "qtyInProgress": 0,
                    "monteCarloP80": 0
                }
            },
            {
                "__typename": "ReplenishingConsolidation",
                "id": "28233",
                "project": {
                    "__typename": "Project",
                    "id": "686",
                    "name": "Pactera Edge Support",
                    "remainingWeeks": 21,
                    "remainingBacklog": 19,
                    "flowPressure": 0.14383561643835616,
                    "flowPressurePercentage": 0,
                    "leadTimeP80": 339940.1788,
                    "qtySelected": 0,
                    "qtyInProgress": 1,
                    "monteCarloP80": 96
                }
            },
            {
                "__typename": "ReplenishingConsolidation",
                "id": "28234",
                "project": {
                    "__typename": "Project",
                    "id": "685",
                    "name": "IstoÉ Suporte",
                    "remainingWeeks": 47,
                    "remainingBacklog": 0,
                    "flowPressure": 0,
                    "flowPressurePercentage": 0,
                    "leadTimeP80": 1481111.4258000003,
                    "qtySelected": 0,
                    "qtyInProgress": 1,
                    "monteCarloP80": 13.2
                }
            },
            {
                "__typename": "ReplenishingConsolidation",
                "id": "28237",
                "project": {
                    "__typename": "Project",
                    "id": "664",
                    "name": "CONECTE-SE",
                    "remainingWeeks": 1,
                    "remainingBacklog": 0,
                    "flowPressure": 0,
                    "flowPressurePercentage": 0,
                    "leadTimeP80": 1494858,
                    "qtySelected": 0,
                    "qtyInProgress": 2,
                    "monteCarloP80": 3
                }
            }
        ]
    }
}
