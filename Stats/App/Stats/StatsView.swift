//
//  StatsView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import Charts
import DependencyInjection
import Models
import SwiftUI
import SwiftDate
import Networking

struct StatsView: View {

    @EnvironmentObject var dataLoader: NetworkDataLoader
    
    @StateObject private var viewModel = StatsViewModel()
    
    var body: some View {
        ZStack {
            switch dataLoader.state {

            case .success(let response):
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading) {
                            Text("Stats")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                        }
                        
                        timePeriodView
                        
                        timeFilterView
                        
                        chartView
                            .padding(.vertical)
                        
                        chartListData
                        
                    }
                    .padding()
                    .animation(.default, value: viewModel.dateRange)
                }
                .task {
                    viewModel.generateChartData(from: response)
                }

            case .loading:
                ProgressView()

            case .failed(let error):
                GenericErrorView(error: error.localizedDescription) {
                    await dataLoader.load()
                }
            }
        }.animation(.default, value: dataLoader.state)
    }
    
    private var timeFilterView: some View {
        Picker("Time filter", selection: $viewModel.timeFilter) {
            ForEach(StatsViewModel.TimeFilterType.allCases, id: \.rawValue) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var timePeriodView: some View {
        HStack {
            Button {
                viewModel.shiftIndex = -1
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
            }
            .foregroundColor(viewModel.previousEnabled ? .secondary.opacity(0.8) : .secondary.opacity(0.3))
            .disabled(!viewModel.previousEnabled)
            
            Spacer()
            
            if viewModel.timeFilter != .week {
                Menu {
                    switch viewModel.timeFilter {
                    case .month:
                        Picker("", selection: Binding(get: { viewModel.currentSelectedDate }, set: {
                            viewModel.customDate = .init(month: $0.month, year: $0.year)
                        })) {
                            ForEach(viewModel.availableMonthsAndYears) { date in
                                Text(date.formatted ?? "").tag(date)
                            }
                        }
                    case .year:
                        Picker("", selection: Binding(get: { viewModel.currentSelectedYear }, set: {
                            viewModel.customDate = .init(month: nil, year: $0)
                        })) {
                            ForEach(viewModel.availableYears, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                    case .week:
                        EmptyView()
                    }
                    
                } label: {
                    HStack(spacing: 5) {
                        Text(viewModel.dateIntervalFormatted)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.primary.opacity(0.8))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                Text(viewModel.dateIntervalFormatted)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
            }
            
            Spacer()
            
            Button {
                viewModel.shiftIndex = 1
            } label: {
                Image(systemName: "chevron.forward.circle.fill")
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
            }
            .foregroundColor(viewModel.nextEnabled ? .secondary.opacity(0.8) : .secondary.opacity(0.3))
            .disabled(!viewModel.nextEnabled)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(.gray.opacity(0.18), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .padding(.top, 10)
    }
    
    private var chartView: some View {
        Chart {
            ForEach(viewModel.filteredChartData) { value in
                BarMark(
                    x: .value("Date", value.item.lastWatched, unit: .day),
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
            
            if let gestureRange = viewModel.gestureRange {
                RectangleMark(
                    xStart: .value("Range start", gestureRange.lowerBound),
                    xEnd: .value("Range end", gestureRange.upperBound)
                )
                .foregroundStyle(.gray.opacity(0.2))
            }

        }
        .frame(height: 300)
        .chartXScale(domain: viewModel.dateRange)
        .chartYScale(domain: .automatic(dataType: Int.self) { domain in
            if let last = domain.last, last > 0, last < 6 {
                domain.append(last + 1)
            }
        })
        .chartForegroundStyleScale([
            "Movies": .blue, "Shows": .green
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
                        .onChanged({ value in
                            let startX = value.startLocation.x - reader[proxy.plotAreaFrame].origin.x
                            let currentX = value.location.x - reader[proxy.plotAreaFrame].origin.x
                            if let startDate: Date = proxy.value(atX: startX),
                               let currentDate: Date = proxy.value(atX: currentX), startDate != currentDate {
                                viewModel.gestureRange = startDate < currentDate ? (startDate ... currentDate) : (currentDate ... startDate)
                            }
                        })
                    )
                    .onTapGesture { location in
                        let xPosition = location.x - reader[proxy.plotAreaFrame].origin.x
                        if let selectedDate: Date = proxy.value(atX: xPosition) {
                            viewModel.gestureTap = selectedDate
                        }
                    }
            }
        }
        .chartOverlay(alignment: .topLeading) { _ in
            if let additionalText = viewModel.additionalText {
                HStack {
                    Text(additionalText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button("clear") {
                        viewModel.clearAll()
                    }
                }
            }
        }
    }
    
    private var chartListData: some View {
        VStack(alignment: .leading) {
            Text("Details")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            
            LazyVStack(alignment: .leading) {
                
                GridView(width: 80) {
                    ForEach(viewModel.filteredChartListData.sorted(by: { $0.item.lastWatched > $1.item.lastWatched })) { value in
                        ChartGridItemView(
                            title: value.item.title,
                            subtitle: value.item.lastWatched.formatted(date: .numeric, time: .omitted) + ", " + value.item.lastWatched.formatted(date: .omitted, time: .shortened),
                            imageURL: URL(string: (API.baseImageUrl + value.item.image).urlEncoded)
                        )
                    }
                }
            }
        }
        .animation(.default, value: viewModel.gestureRange)
        .animation(.default, value: viewModel.gestureTap)
    }
}

/*struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}*/

struct StatsView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            StatsView()
                .task {
                    // DependencyValues[\.networkService] = .mock(movies: [.inception, .blonde, .donnieDarko, .inception])
                    DependencyValues[\.persistenceService] = .mock
                    await dataLoader.load()
                }
                .environmentObject(dataLoader)
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






