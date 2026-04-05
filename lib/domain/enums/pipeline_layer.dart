enum PipelineLayer {
  ingest(1, 'Ingest'),
  signalExtraction(2, 'Signal Extraction'),
  semanticAnalysis(3, 'Semantic Analysis'),
  classification(4, 'Classification'),
  scoringSegmentation(5, 'Scoring & Segmentation'),
  editDecisionList(6, 'Edit Decision List'),
  rendering(7, 'Rendering'),
  qualityControl(8, 'Quality Control');

  final int number;
  final String name;

  const PipelineLayer(this.number, this.name);

  static PipelineLayer fromNumber(int n) {
    return PipelineLayer.values.firstWhere(
      (v) => v.number == n,
      orElse: () => PipelineLayer.ingest,
    );
  }

  static String nameFor(int n) {
    return fromNumber(n).name;
  }
}
