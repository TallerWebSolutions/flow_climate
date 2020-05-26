function getScoreMatrixQuestions(scoreMatrixId, questionsDimension) {
    jQuery.ajax({
        url: `/score_matrices/${scoreMatrixId}/score_matrix_dimensions.js`,
        type: "GET",
        data: `&questions_dimensions=${questionsDimension}`
    });
}
