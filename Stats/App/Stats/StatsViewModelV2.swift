//
//  StatsViewModelV2.swift
//  Stats
//
//  Created by ned on 05/11/22.
//

import Foundation
import Models
import SwiftDate
import Charts

@MainActor final class StatsViewModelV2: ObservableObject {
    
    // Data
    @Published private(set) var globalChartData: [ChartData] = []
    @Published private(set) var globalDateRange: DateRange = .now
    
    // UI
    @Published var timeFilter: TimeFilter = .threeMonths { didSet { shiftIndex = 0 } }
    @Published var shiftIndex: Int = 0
    
    let apiResponse: APIResponse
    
    private let currentDate = DateInRegion(region: .current)
    
    init(apiResponse: APIResponse) {
        self.apiResponse = apiResponse
        
        let moviesData: [ChartData] = apiResponse.movies
            .filter({ $0.lastWatched.dateComponents.year! >= 2021 })
            .map { ChartData(id: $0.id, date: $0.lastWatched, group: .movies) }
        
        let showsData: [ChartData] = apiResponse.tvShows
            .flatMap(\.episodes)
            .filter({ $0.lastWatched.dateComponents.year! >= 2021 })
            .map { ChartData(id: $0.id, date: $0.lastWatched, group: .shows) }
        
        self.globalChartData = (moviesData + showsData)
        
        let allDates = globalChartData.map(\.date).sorted()
        if let minDate = allDates.min(), let maxDate = allDates.max() {
            self.globalDateRange = .init(lower: minDate, upper: maxDate)
        }
    }
}

// MARK: - Computed vars
extension StatsViewModelV2 {
    
    var filteredChartData: [ChartData] {
        globalChartData.filter({ filteredDateRange.range.contains($0.date) })
    }
    
    var filteredDateRange: DateRange {
        if shiftIndex != .zero {
            
            let times = abs(shiftIndex-1)
            let multiplier = shiftIndex > 0 ? timeFilter.multiplier : -timeFilter.multiplier
            
            var startDate: Date = currentDate
                .dateByAdding(multiplier*times, timeFilter.component)
                .date
            
            var endDate = startDate
                .dateByAdding(-multiplier, timeFilter.component)
                .date
            
            startDate = globalDateRange.lower <= startDate ? startDate : globalDateRange.lower
            endDate = globalDateRange.upper >= endDate ? endDate : globalDateRange.upper
            
            return .init(lower: startDate.dateAtStartOf(mainChartUnit), upper: endDate.dateAtEndOf(mainChartUnit))
        }
        
        let startDate: Date = currentDate
            .dateByAdding(-timeFilter.multiplier, timeFilter.component)
            .dateAtStartOf(mainChartUnit)
            .date
        
        let endDate = currentDate.dateAtEndOf(mainChartUnit).date
        
        return .init(lower: startDate, upper: endDate)
    }
    
    var previousEnabled: Bool {
        return globalDateRange.lower < filteredDateRange.lower
    }
    
    var nextEnabled: Bool {
        return globalDateRange.upper > filteredDateRange.upper
    }
    
    var dateIntervalFormatted: String {
        dateIntervalFormatter.string(from: filteredDateRange.lower, to: filteredDateRange.upper)
    }
    
    var xAxisStride: Calendar.Component {
        switch timeFilter {
        case .year, .sixMonths: return .month
        case .threeMonths: return .weekOfYear
        case .month, .week: return .day
        }
    }
    
    var xAxisStrideCount: Int {
        switch timeFilter {
        case .year: return 2
        case .threeMonths: return 2
        case .sixMonths: return 1
        case .month: return 5
        case .week: return 1
        }
    }
    
    var mainChartUnit: Calendar.Component {
        switch timeFilter {
        case .year, .sixMonths: return .weekOfYear
        case .threeMonths: return .weekOfYear
        case .month, .week: return .day
        }
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
extension StatsViewModelV2 {
    
    struct DateRange: Equatable {
        let lower: Date
        let upper: Date
        
        var range: ClosedRange<Date> {
            lower...upper
        }
        
        static let now: Self = .init(lower: .now, upper: .now)
        
        func contains(_ date: Date) -> Bool {
            range.contains(date)
        }
        
        static func == (lhs: DateRange, rhs: DateRange) -> Bool {
            lhs.lower.compare(.isSameDay(rhs.lower)) &&
            lhs.upper.compare(.isSameDay(rhs.upper))
        }
    }
    
    enum ChartGroupType: String, Plottable {
        case movies = "Movies"
        case shows = "Shows"
    }
    
    struct ChartData: Identifiable, Equatable {
        let id: String
        let date: Date
        let group: ChartGroupType
    }
    
    enum TimeFilter: String, CaseIterable {
        case week = "W"
        case month = "M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case year = "Y"
        
        var component: Calendar.Component {
            switch self {
            case .year: return .year
            case .month, .threeMonths, .sixMonths: return .month
            case .week: return .weekOfYear
            }
        }
        
        var multiplier: Int {
            switch self {
            case .threeMonths: return 3
            case .sixMonths: return 6
            default: return 1
            }
        }
    }
}
