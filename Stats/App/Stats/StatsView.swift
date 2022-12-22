//
//  StatsView.swift
//  Stats
//
//  Created by ned on 05/11/22.
//

import Charts
import DependencyInjection
import Models
import Networking
import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @EnvironmentObject var dataLoader: NetworkDataLoader
    @Environment(\.dismiss) private var dismiss

    @State private var selection: Media? = nil
    @State private var showDetails: Bool = false
    @State private var sheetContentHeight: CGFloat = 190

    var body: some View {
        VStack(spacing: 0) {
            titleView
                .padding()

            Divider()

            ZStack {
                switch dataLoader.state {
                case let .success(response):
                    ScrollView {
                        VStack(alignment: .leading) {
                            timeFilterView
                                .padding(.top)

                            dateRangeView
                                .padding(.vertical, 10)

                            chartView
                                .frame(height: 300)
                                .animation(.default, value: viewModel.filteredChartData)

                            HStack {
                                Text("Details")
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                
                                Spacer()
                                
                                Text("\(viewModel.nMovies) movies, \(viewModel.nEpisodes) episodes")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                            .padding(.top)

                            chartListData
                                .animation(.default, value: viewModel.filteredGridListData)
                        }
                        .padding()
                    }
                    .task {
                        viewModel.generateData(with: response)
                    }

                case .loading:
                    ProgressView()

                case let .failed(error):
                    GenericErrorView(error: error.localizedDescription) {
                        await dataLoader.load()
                    }
                }
            }.animation(.default, value: dataLoader.state)
        }
    }

    private var titleView: some View {
        HStack {
            Text("Stats")
                .font(.system(size: 22, weight: .semibold, design: .rounded))

            Spacer()

            miniChartView
                .frame(height: 20)
                .padding(.horizontal, 30)
                .offset(y: -2)
                .animation(.default.delay(0.5), value: viewModel.timeFilter)
                .animation(.default.delay(0.5), value: viewModel.shiftIndex)

            Spacer()

            closeButton
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary.opacity(0.7))
        }
    }

    private var timeFilterView: some View {
        Picker("Time filter", selection: $viewModel.timeFilter) {
            ForEach(StatsViewModel.TimeFilter.allCases, id: \.rawValue) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }

    private var dateRangeView: some View {
        HStack {
            Button {
                viewModel.shiftIndex -= 1
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
            }
            .foregroundColor(viewModel.previousEnabled ? .secondary.opacity(0.8) : .secondary.opacity(0.3))
            .disabled(!viewModel.previousEnabled)

            Text(viewModel.dateIntervalFormatted)
                .font(.subheadline)
                .frame(maxWidth: .infinity)

            Button {
                viewModel.shiftIndex += 1
            } label: {
                Image(systemName: "chevron.forward.circle.fill")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
            }
            .foregroundColor(viewModel.nextEnabled ? .secondary.opacity(0.8) : .secondary.opacity(0.3))
            .disabled(!viewModel.nextEnabled)
        }
    }

    private var miniChartView: some View {
        Chart {
            ForEach(viewModel.globalChartData) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .month),
                    y: .value("Watches", 1)
                )
                .foregroundStyle(.gray)
                .opacity(0.4)
            }
            RectangleMark(
                xStart: .value("Range start", viewModel.filteredDateRange.lower),
                xEnd: .value("Range end", viewModel.filteredDateRange.upper.dateAtEndOf(.month))
            )
            .foregroundStyle(.gray.opacity(0.2))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
    }

    private var chartView: some View {
        Chart {
            ForEach(viewModel.filteredChartData) { value in
                BarMark(
                    x: .value("Date", value.date, unit: viewModel.mainChartUnit),
                    y: .value("Watches", 1)
                )
                .foregroundStyle(by: .value("", value.group.rawValue))
            }

            if viewModel.filteredChartData.isEmpty {
                RuleMark(y: .value("No content", 0))
                    .foregroundStyle(.clear)
                    .annotation(position: .overlay, alignment: .center) {
                        Text("No content for this period")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
            }

            if let gestureRange = (viewModel.gestureRangeLiveDrag ?? viewModel.gestureRange) {
                RectangleMark(
                    xStart: .value("Range start", gestureRange.lower),
                    xEnd: .value("Range end", gestureRange.upper)
                )
                .foregroundStyle(.gray.opacity(0.2))
            }
        }
        .chartXScale(domain: viewModel.filteredDateRange.range)
        .chartYScale(domain: .automatic(dataType: Int.self) { domain in
            if let last = domain.last, last > 0, last < 6 {
                domain.append(last + 1)
            }
        })
        .chartForegroundStyleScale([
            StatsViewModel.ChartGroupType.movies: .blue,
            StatsViewModel.ChartGroupType.shows: .green,
        ])
        .chartXAxis {
            AxisMarks(values: .stride(by: viewModel.xAxisStride, count: viewModel.xAxisStrideCount))
        }
        .chartLegend(alignment: .trailing, spacing: -15)
        .chartXAxisLabel(alignment: .leading) {
            Label {
                Text("Date")
                    .font(.subheadline)
            } icon: {
                Image(systemName: "calendar")
                    .font(.caption)
            }
            .frame(minWidth: 200, alignment: .leading)
        }
        .chartYAxisLabel(alignment: .trailing) {
            Label {
                Text("Content watched")
                    .font(.subheadline)
            } icon: {
                Image(systemName: "tv")
                    .font(.caption)
            }
            .frame(minWidth: 200, alignment: .trailing)
            .padding(.bottom, 5)
        }
        .chartOverlay { proxy in
            GeometryReader { reader in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture()
                        .onChanged { value in
                            let startX = value.startLocation.x - reader[proxy.plotAreaFrame].origin.x
                            let currentX = value.location.x - reader[proxy.plotAreaFrame].origin.x
                            if let startDate: Date = proxy.value(atX: startX),
                               let currentDate: Date = proxy.value(atX: currentX),
                               !startDate.compare(.isSameDay(currentDate)),
                               viewModel.filteredDateRange.contains(startDate),
                               viewModel.filteredDateRange.contains(currentDate)
                            {
                                viewModel.gestureRangeLiveDrag = .init(lower: startDate, upper: currentDate)
                            }
                        }
                        .onEnded { _ in
                            viewModel.gestureRange = viewModel.gestureRangeLiveDrag
                            viewModel.gestureRangeLiveDrag = nil
                        }
                    )
                    .onTapGesture { location in
                        let xPosition = location.x - reader[proxy.plotAreaFrame].origin.x
                        if let _: Date = proxy.value(atX: xPosition) {
                            viewModel.clearSelection()
                        }
                    }
            }
        }
        .chartOverlay(alignment: .topLeading) { _ in
            if let _ = viewModel.gestureRangeLiveDrag {
                releaseToApplyView
            } else if let _ = viewModel.gestureRange {
                filterTextView
            }
        }
    }

    private var releaseToApplyView: some View {
        HStack(spacing: 5) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.vertical, 3)

            Text("Release to apply filter")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }.offset(y: -4)
    }

    private var filterTextView: some View {
        Button {
            viewModel.clearSelection()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "trash")
                    .font(.system(size: 10))
                Text("Clear selection")
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background(.secondary.opacity(0.6), in: Capsule(style: .continuous))
        }
        .foregroundColor(.secondary.opacity(0.8))
        .offset(y: -1)
    }

    private var chartListData: some View {
        VStack(alignment: .leading) {
            if viewModel.filteredGridListData.isEmpty {
                VStack {
                    Text("No content for this period")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
            } else {
                GridView {
                    ForEach(viewModel.filteredGridListData) { item in
                        MediaGridItemView(
                            title: item.title,
                            subtitle: item.subtitle,
                            imageURL: item.imageURL,
                            aspectRatio: 0.7,
                            circle: false
                        ) {
                            self.selection = item.asMedia
                            self.showDetails = true
                        }
                    }
                }
                .sheet(isPresented: $showDetails, content: {
                    let hasEpisodes = !((selection as? TVShow)?.episodes.isEmpty ?? true)
                    MediaDetailView(media: $selection)
                        .if(hasEpisodes, transform: { view in
                            view
                                .presentationDetents([.medium, .large])
                        })
                        .if(!hasEpisodes, transform: { view in
                            view
                                .readSize(onChange: { size in
                                    sheetContentHeight = size.height
                                })
                                .presentationDetents([.height(sheetContentHeight)])
                        })
                })
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            StatsView()
                .environmentObject(dataLoader)
                .task {
                    DependencyValues[\.persistenceService] = .mock
                    await dataLoader.load()
                }
        }
    }

    static var previews: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: .init(colors: [Color("bg_color"), .purple.opacity(0.5)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                    .opacity(0.5)
                    .ignoresSafeArea()
                Preview()
            }
        }.environment(\.colorScheme, .dark)
    }
}
