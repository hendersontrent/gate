
gs_dis <- dissolve(greater_sydney)

test_that("dissolve works", {
  expect_equal(1, nrow(gs_dis))
})

test_that("segment works", {
  expect_equal(10, nrow(segment(gs_dis, n_zones = 10, n_points = 1e4, seed = 123)))
})
