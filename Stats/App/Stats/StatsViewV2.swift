//
//  StatsViewV2.swift
//  Stats
//
//  Created by ned on 05/11/22.
//

import SwiftUI
import DependencyInjection
import Charts
import Networking

struct StatsViewV2: View {
    
    @StateObject private var viewModel: StatsViewModelV2
        
    init(viewModel: @autoclosure @escaping () -> StatsViewModelV2) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                HStack(alignment: .bottom) {
                    Text("Stats")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    Spacer()
                    miniChartView
                        .frame(height: 20)
                        .padding(.horizontal, 8)
                        .offset(y: -5)
                        .animation(.default.delay(0.5), value: viewModel.timeFilter)
                        .animation(.default.delay(0.5), value: viewModel.shiftIndex)
                }
                
                timeFilterView
                
                dateRangeView
                    .padding(.vertical)
                
                chartView
                    .frame(height: 300)
                    .animation(.default, value: viewModel.filteredDateRange)
                
                Text("Details")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.top)
                
                chartListData
                    .animation(.default, value: viewModel.filteredDateRange)
                
            }
            .padding()
        }
    }
    
    private var timeFilterView: some View {
        Picker("Time filter", selection: $viewModel.timeFilter) {
            ForEach(StatsViewModelV2.TimeFilter.allCases, id: \.rawValue) { type in
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
        /*.chartOverlay { proxy in
            GeometryReader { reader in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture()
                        .onChanged{ value in
                            let startX = value.startLocation.x - reader[proxy.plotAreaFrame].origin.x
                            let currentX = value.location.x - reader[proxy.plotAreaFrame].origin.x
                            if let startDate: Date = proxy.value(atX: startX),
                               let currentDate: Date = proxy.value(atX: currentX),
                               startDate != currentDate,
                               let diff = startDate.difference(in: .day, from: currentDate) {
                                viewModel.dayShift = abs(diff)
                            }
                        }
                        .onEnded { _ in viewModel.dayShift = 0 }
                    )
            }
        }*/
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
        }
        .chartXScale(domain: viewModel.filteredDateRange.range)
        .chartYScale(domain: .automatic(dataType: Int.self) { domain in
            if let last = domain.last, last > 0, last < 6 {
                domain.append(last + 1)
            }
        })
        .chartForegroundStyleScale([
            StatsViewModelV2.ChartGroupType.movies: .blue,
            StatsViewModelV2.ChartGroupType.shows: .green
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
        }
    }
    
    @ViewBuilder private var chartListData: some View {
        if viewModel.filteredGridListData.isEmpty {
            VStack {
                Text("No content for this period")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
        } else {
            LazyVStack(alignment: .leading) {
                GridView {
                    ForEach(viewModel.filteredGridListData) { item in
                        ChartGridItemView(
                            title: item.title,
                            subtitle: item.subtitle,
                            imageURL: URL(string: (API.baseImageUrl + item.image).urlEncoded)
                        )
                    }
                }
            }
        }
        //.animation(.default, value: viewModel.gestureRange)
        //.animation(.default, value: viewModel.gestureTap)
    }
}

struct StatsViewV2_Previews: PreviewProvider {
    
    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            VStack {
                switch dataLoader.state {
                case .success(let response):
                    StatsViewV2(viewModel: .init(apiResponse: response))
                default:
                    ProgressView()
                }
            }
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
