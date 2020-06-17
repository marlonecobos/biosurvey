#' Selection of blocks in environmental space
#'
#' @description select a user defined number of blocks in environmental space
#' to be used in further analysis in order to define sampling sites for a survey
#' system.
#'
#' @param master_matrix object derived from function \code{\link{master_matrix}}.
#' @param variable_1 (character or numeric) name or position of the first
#' variable (X axis).
#' @param variable_2 (character or numeric) name or position of the second
#' variable (Y axis) to be used to create blocks (must be different from the
#' first one).
#' @param expected_blocks (numeric) number of blocks to be selected.
#' @param selection_type (character) Type of selection. Two options are available:
#' "uniform" and "random". Default = "uniform".
#' @param initial_distance (numeric) euclidean distance to be used for a first
#' process of thinning and detection of remaining points. If \code{selection_type}
#' = "uniform", this argument must be defined. Default = NULL.
#' @param increase (numeric) value to be added to \code{initial_distance} until
#' reaching the number of \code{expected_points}. If \code{selection_type}
#' = "uniform", this argument must be defined. Default = NULL.
#' @param replicates (numeric) number of thinning replicates performed to select
#' blocks uniformly. Default = 10.
#' @param set_seed (numeric) integer value to specify a initial seed. Default = 1.
#'
#' @details
#' When blocks in \code{master_matrix} were defined using the option "equal_poinst"
#' (see \code{\link{make_blocks}}), "uniform" \code{selection_type} could result
#' in blocks with high density per area being overlooked.
#'
#' @return
#' An S3 object of class master_matrix, containing the same elements found in the
#' input master_matrix object, with an aditional column in the master_matrix
#' data.frame containing a binary code for selected (1) and non-selected (0) blocks.
#'
#' @usage
#' block_sample(master_matrix, variable_1, variable_2, expected_blocks,
#'              selection_type = "uniform", initial_distance = NULL,
#'              increase = NULL, replicates = 10, set_seed = 1)
#'
#' @export
#'
#' @examples
#' # Data
#' data("m_matrix", package = "biosurvey")
#'
#' # Making blocks for analysis
#' m_blocks <- make_blocks(m_matrix, variable_1 = "PC1",
#'                         variable_2 = "PC2", n_cols = 10, n_rows = 10,
#'                         block_type = "equal_area")
#'
#' # Checking column names and values in variables to define initial distance
#' colnames(m_blocks$master_matrix)
#' summary(m_blocks$master_matrix[, c("PC1", "PC2")])
#'
#' # Selecting Blocks uniformly in E space
#' block_sel <- block_sample(m_blocks, variable_1 = "PC1", variable_2  = "PC2",
#'                           expected_blocks = 10, selection_type = "uniform",
#'                           initial_distance = 1.5, increase = 0.1)
#'
#' head(block_sel$master_matrix)


block_sample <- function(master_matrix, variable_1, variable_2, expected_blocks,
                         selection_type = "uniform", initial_distance = NULL,
                         increase = NULL, replicates = 10, set_seed = 1) {
  # initial tests
  if (missing(master_matrix)) {
    stop("Argument 'master_matrix' needs to be defined.")
  }
  if (class(master_matrix)[1] != "master_matrix") {
    stop("Object defined in 'master' is not valid, see function's help.")
  }
  if (is.null(master_matrix$master_matrix$Block)) {
    stop("Blocks are not defined in master_matrix, see function 'make_blocks'.")
  }
  if (missing(variable_1)) {
    stop("Argument 'variable_1' needs to be defined.")
  }
  if (missing(variable_2)) {
    stop("Argument 'variable_2' needs to be defined.")
  }
  if (missing(expected_blocks)) {
    stop("Argument 'expected_blocks' needs to be defined.")
  }
  if (!selection_type[1] %in% c("uniform", "random")) {
    stop("Argument 'selection_type' is not valid, see function's help.")
  }

  # block selection
  if (selection_type[1] == "uniform") {
    if (any(is.null(initial_distance), is.null(increase))) {
      stop("If 'selection_type' = uniform, the following arguments must be defined:\n'initial_distance', 'increase'")
    }
    pairs_sel <- uniformE_selection(master_matrix, variable_1, variable_2,
                                    selection_from = "block_centroids",
                                    expected_blocks, max_n_samples = 1,
                                    initial_distance, increase, replicates,
                                    set_seed)
    pairs_sel <- pairs_sel$selected_sites_E$selection_1$Block
  } else {
    pairs_sel <- sample(unique(master_matrix$master_matrix$Block),
                        expected_blocks)
  }

  # preparing results
  pairs_sel <- ifelse(master_matrix$master_matrix$Block %in% pairs_sel, 1, 0)
  master_matrix$master_matrix$Selected_blocks <- pairs_sel

  return(master_matrix)
}