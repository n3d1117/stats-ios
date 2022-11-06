//
//  StatsViewModel.swift
//  Stats
//
//  Created by ned on 02/11/22.
//

import Foundation
import Models
import SwiftDate

extension Array {
  func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date>) -> [Date: [Element]] {
    let initial: [Date: [Element]] = [:]
    let groupedByDateComponents = reduce(into: initial) { acc, cur in
      let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
      let date = Calendar.current.date(from: components)!
      let existing = acc[date] ?? []
      acc[date] = existing + [cur]
    }
    return groupedByDateComponents
  }
}

extension ClosedRange where Bound == Date {
    func shifted(by index: Int, _ component: Calendar.Component) -> ClosedRange<Date> {
        let shiftedStart = lowerBound.in(region: .current).dateByAdding(index, component).dateAtStartOf(component).date
        let shiftedEnd = upperBound.in(region: .current).dateByAdding(index, component).dateAtEndOf(component).date
        return shiftedStart...shiftedEnd
    }
}

@MainActor final class StatsViewModel: ObservableObject {
    
    @Published private(set) var filteredChartData: [SingleWatch] = []
    @Published private(set) var filteredChartListData: [SingleWatch] = []
    @Published var dateRange: ClosedRange<Date> = .init(uncheckedBounds: (.now, .now))
    
    @Published var gestureTap: Date? = nil { didSet { onTapGestureChange() } }
    @Published var gestureRange: ClosedRange<Date>? = nil { didSet { onDragGestureChange() } }
    @Published var customDate: CustomDate = .now { didSet { onCustomDateChange() } }
    @Published var timeFilter: TimeFilterType = .month { didSet { onTimeFilterChange() } }
    @Published var shiftIndex: Int = 0 { didSet { updateChartData() } }
    
    private var originalData: [SingleWatch] = [] { didSet { updateChartData() } }
    private var minDate: Date?
    private var maxDate: Date?
    
    func generateChartData(from response: APIResponse) {
        let moviesData: [SingleWatch] = response.movies
            .filter({ $0.lastWatched.dateComponents.year! >= 2021 })
            .sliced(by: [.year, .month, .day], for: \.lastWatched).flatMap { day, movies in
                movies.map { SingleWatch(item: $0.asChartRepresentable(), group: .movies) }
            }
        
        let showsData: [SingleWatch] = response.tvShows
            .flatMap(\.episodes)
            .filter({ $0.lastWatched.dateComponents.year! >= 2021 })
            .sliced(by: [.year, .month, .day], for: \.lastWatched).flatMap { day, episodes in
                episodes.compactMap { ep in
                    if let parent: TVShow = response.tvShows.filter({ show in
                        show.id == ep.parentShowID
                    }).first {
                        return SingleWatch(item: ep.asChartRepresentable(parent: parent), group: .shows)
                    } else {
                        return nil
                    }
                }
            }
        
        let combined: [SingleWatch] = (moviesData + showsData)
        
        let dates = combined.map(\.item.lastWatched).sorted()
        minDate = dates.min()
        maxDate = dates.max()
        
        dateRange = initialRange()
        originalData = combined
    }
    
    private func initialRange() -> ClosedRange<Date> {
        let startDate = DateInRegion(region: .current).dateAtStartOf(timeFilter.component).date
        let endDate = DateInRegion(region: .current).dateAtEndOf(timeFilter.component).date
        let range: ClosedRange<Date> = startDate ... endDate
        return range
    }
    
    func onTapGestureChange() {
        if let gestureTap {
            filteredChartListData = originalData
                .filter({ gestureTap.isInside(date: $0.item.lastWatched, granularity: .day) })
            
            gestureRange = nil
            
            if filteredChartListData.isEmpty {
                self.gestureTap = nil
            }
        } else if filteredChartListData.isEmpty {
            //if gestureRange != nil { gestureRange = nil }
            //filteredChartListData = filteredChartData
        }
    }
    
    func onDragGestureChange() {
        if let gestureRange {
            filteredChartListData = originalData
                .filter({ gestureRange.contains($0.item.lastWatched) })
            
            gestureTap = nil
        } else if filteredChartListData.isEmpty {
            if gestureTap != nil { gestureTap = nil }
            filteredChartListData = filteredChartData
        }
    }
    
    func clearAll() {
        if gestureTap != nil { gestureTap = nil }
        if gestureRange != nil { gestureRange = nil }
        filteredChartListData = filteredChartData
    }
    
    func onCustomDateChange() {
        switch timeFilter {
        case .year:
            shiftIndex = customDate.year - dateRange.upperBound.year
        case .month:
            var monthDifference: Int = 0
            if let month = customDate.month { monthDifference = month - dateRange.upperBound.month }
            let yearDifference = customDate.year - dateRange.upperBound.year
            shiftIndex = monthDifference + yearDifference*12
        default:
            break
        }
    }
    
    func onTimeFilterChange() {
        shiftIndex = 0
    }
    
    func updateChartData() {
        gestureTap = nil
        gestureRange = nil
        guard let maxDate else { return }
        
        let newStart = dateRange.upperBound.in(region: .current).dateAtStartOf(timeFilter.component).date
        let newEnd = dateRange.upperBound.in(region: .current).dateAtEndOf(timeFilter.component).date
        var newRange = (newStart ... newEnd).shifted(by: shiftIndex, timeFilter.component)
        
        while newRange.lowerBound > maxDate {
            newRange = newRange.shifted(by: -1, timeFilter.component)
        }
        
        dateRange = newRange
        filteredChartData = originalData.filter({ dateRange.contains($0.item.lastWatched) })
        filteredChartListData = filteredChartData
        
        /*filteredChartListData = a.compactMap({ title, watches in
            if let title, let w = watches.first {
                let c = ChartRepresentable(title: title, subtitle: nil, image: w.item.image, lastWatched: w.item.lastWatched)
                return SingleWatch(item: c, count: watches.count, group: .shows)
            } else if let w = watches.first {
                return w
            }
            return nil
        })*/
    }
    
    var dateIntervalFormatted: String {
        if let gestureRange {
            return dateIntervalFormatter.string(from: gestureRange.lowerBound, to: gestureRange.upperBound)
        } else {
            return dateIntervalFormatter.string(from: dateRange.lowerBound, to: dateRange.upperBound)
        }
    }
    
    var additionalText: String? {
        if (gestureRange != nil || gestureTap != nil), !filteredChartListData.isEmpty {
            return "\(filteredChartListData.count) selected"
        }
        return nil
    }
    
    var currentSelectedDate: CustomDate {
        .init(month: dateRange.upperBound.month, year: dateRange.upperBound.year)
    }
    
    var currentSelectedYear: Int {
        dateRange.upperBound.year
    }
    
    var previousEnabled: Bool {
        guard let minDate else { return true }
        return minDate < dateRange.lowerBound
    }
    
    var nextEnabled: Bool {
        guard let maxDate else { return false }
        return maxDate > dateRange.upperBound
    }
    
    var availableMonthsAndYears: [CustomDate] {
        guard let minDate, let maxDate else { return [] }
        let minYear = minDate.year
        let maxYear = maxDate.year
        var final: [CustomDate] = []
        SwiftDate.defaultRegion = .current
        (minYear...maxYear).forEach { year in
            for monthIndex in 1..<13 {
                guard let date = DateInRegion(components: .init(year: year, month: monthIndex, day: 10), region: .current)?.date else {
                    continue
                }
                guard date.isInRange(date: minDate.dateAtStartOf(.month), and: maxDate.dateAtEndOf(.month)) else {
                    continue
                }
                final.append(.init(month: monthIndex, year: year))
            }
        }
        return final.reversed()
    }
    
    var availableYears: [Int] {
        guard let minDate, let maxDate else { return [] }
        return Array(minDate.year...maxDate.year).reversed()
    }
    
    var xAxisStride: Calendar.Component {
        switch timeFilter {
        case .year: return .month
        case .month, .week: return .day
        }
    }
    
    var xAxisStrideCount: Int {
        switch timeFilter {
        case .year: return 2
        case .month: return 5
        case .week: return 1
        }
    }
    
    var yRange: ClosedRange<Int> {
        return 0...(Dictionary(grouping: filteredChartData, by: { $0.item.lastWatched.in(region: .current).day }).map({ $0.1.count }).max() ?? -1) + 1
    }
    
    // MARK: - Private
    private var dateIntervalFormatter: DateIntervalFormatter {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
}

// MARK: - Utilities
extension StatsViewModel {
    
    enum TimeFilterType: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var component: Calendar.Component {
            switch self {
            case .year: return .year
            case .month: return .month
            case .week: return .weekOfYear
            }
        }
    }
    
    struct CustomDate: Identifiable, Hashable {
        var id: String { formatted ?? UUID().uuidString }
        
        let month: Int?
        let year: Int
        
        var formatted: String? {
            if let month, let monthName = monthNames?[month-1] {
                return monthName.capitalized + " \(year)"
            }
            return "\(year)"
        }
        
        static let now: Self = .init(
            month: DateInRegion(region: .current).month,
            year: DateInRegion(region: .current).year
        )
        
        private let monthNames = DateFormatter().monthSymbols
    }
    
    struct SingleWatch: Identifiable {
        enum GroupType: String {
            case movies = "Movies"
            case shows = "Shows"
        }
        
        let id = UUID()
        let item: ChartRepresentable
        let group: GroupType

        init(item: ChartRepresentable, group: GroupType) {
            self.item = item
            self.group = group
        }
    }
}

struct ChartRepresentable {
    let title: String
    let subtitle: String?
    let image: String
    let lastWatched: Date
}

extension Movie {
    func asChartRepresentable() -> ChartRepresentable {
        .init(title: title, subtitle: nil, image: image, lastWatched: lastWatched)
    }
}

extension TVShow.Episode {
    func asChartRepresentable(parent: TVShow) -> ChartRepresentable {
        .init(
            title: episode + " - " + name,
            subtitle: parent.title,
            image: parent.image,
            lastWatched: lastWatched
        )
    }
}
