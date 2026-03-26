class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isLastPage => currentPage >= totalPages;
}
