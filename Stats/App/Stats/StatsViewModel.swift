//
//  StatsViewModel.swift
//  Stats
//
//  Created by ned on 05/11/22.
//

import Charts
import Foundation
import Models
import SwiftDate

@MainActor final class StatsViewModel: ObservableObject {
    // Data
    @Published private(set) var globalChartData: [ChartData] = []
    @Published private(set) var globalDateRange: DateRange = .now
    @Published private(set) var filteredDateRange: DateRange = .now

    // UI
    @Published var timeFilter: TimeFilter = .threeMonths { didSet { shiftIndex = 0 } }
    @Published var shiftIndex: Int = 0 { didSet { recalculateFilteredDateRange() } }
    @Published var gestureRange: DateRange?
    @Published var gestureRangeLiveDrag: DateRange?

    // Private vars
    private var apiResponse: APIResponse = .empty
    private let currentDate = DateInRegion(region: .current)

    func generateData(with apiResponse: APIResponse) {
        self.apiResponse = apiResponse

        let moviesData: [ChartData] = apiResponse.movies
            .filter { $0.lastWatched.dateComponents.year! >= 2021 }
            .map { ChartData(id: $0.id, date: $0.lastWatched, group: .movies, dataType: .movie($0)) }

        let showsData: [ChartData] = apiResponse.tvShows
            .flatMap(\.episodes)
            .filter { $0.lastWatched.dateComponents.year! >= 2021 }
            .map { ChartData(id: $0.id, date: $0.lastWatched, group: .shows, dataType: .episode($0)) }

        // data
        globalChartData = (moviesData + showsData)

        // range
        let allDates = globalChartData.map(\.date).sorted()
        if let minDate = allDates.min(), let maxDate = allDates.max() {
            globalDateRange = .init(lower: minDate, upper: maxDate)
        }

        recalculateFilteredDateRange()
    }

    // Calculate new date range based on UI filters
    func recalculateFilteredDateRange() {
        gestureRange = nil
        if shiftIndex != .zero {
            let times = abs(shiftIndex - 1)
            let multiplier = shiftIndex > 0 ? timeFilter.multiplier : -timeFilter.multiplier

            var startDate: Date = currentDate
                .dateByAdding(multiplier * times, timeFilter.component)
                .date
            var endDate = startDate
                .dateByAdding(-multiplier, timeFilter.component)
                .date

            startDate = globalDateRange.lower <= startDate ? startDate : globalDateRange.lower
            endDate = globalDateRange.upper >= endDate ? endDate : globalDateRange.upper

            filteredDateRange = .init(lower: startDate.dateAtStartOf(mainChartUnit), upper: endDate.dateAtEndOf(mainChartUnit))
        } else {
            let startDate: Date = currentDate
                .dateByAdding(-timeFilter.multiplier, timeFilter.component)
                .dateAtStartOf(mainChartUnit)
                .date
            let endDate = currentDate.dateAtEndOf(mainChartUnit).date
            filteredDateRange = .init(lower: startDate, upper: endDate)
        }
    }

    func clearSelection() {
        if gestureRange != nil { gestureRange = nil }
    }
}

// MARK: - Computed vars

extension StatsViewModel {
    var filteredGridListData: [GridListData] {
        var gridData: [GridListData] = []

        var source = filteredChartData

        if let gestureRange {
            source = source.filter { gestureRange.contains($0.date) }
        }

        var eps: [TVShow.Episode] = []
        for d in source {
            switch d.dataType {
            case let .movie(movie):
                gridData.append(.init(.movie(movie)))
            case let .episode(episode):
                eps.append(episode)
            }
        }

        let groupedShows: [TVShow] = Dictionary(grouping: eps, by: { $0.parentShowID }).compactMap { showID, episodes in
            if var fullShow = apiResponse.tvShows.first(where: { $0.id == showID }) {
                fullShow.episodes = episodes
                return fullShow
            }
            return nil
        }

        groupedShows.forEach { gridData.append(.init(.show($0))) }
        return gridData.sorted(by: { $0.date > $1.date })
    }

    var filteredChartData: [ChartData] {
        globalChartData.filter { filteredDateRange.range.contains($0.date) }
    }

    var previousEnabled: Bool {
        return globalDateRange.lower < filteredDateRange.lower
    }

    var nextEnabled: Bool {
        return globalDateRange.upper > filteredDateRange.upper
    }

    var dateIntervalFormatted: String {
        let range: DateRange = gestureRangeLiveDrag ?? filteredDateRange
        return dateIntervalFormatter.string(from: range.range.lowerBound, to: range.range.upperBound).capitalized
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
        case .year: return 3
        case .threeMonths: return 3
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

extension StatsViewModel {
    struct DateRange: Equatable {
        let lower: Date
        let upper: Date

        var range: ClosedRange<Date> {
            lower > upper ? upper ... lower : lower ... upper
        }

        static let now: Self = .init(lower: .now, upper: .now)

        func contains(_ date: Date) -> Bool {
            range.contains(date)
        }

        static func == (lhs: DateRange, rhs: DateRange) -> Bool {
            lhs.lower.compare(.isSameDay(rhs.lower)) && lhs.upper.compare(.isSameDay(rhs.upper))
        }
    }

    enum ChartGroupType: String, Plottable {
        case movies = "Movies"
        case shows = "Shows"
    }

    struct ChartData: Identifiable, Equatable {
        enum DataType: Equatable {
            case movie(Movie)
            case episode(TVShow.Episode)

            static func == (lhs: DataType, rhs: DataType) -> Bool {
                switch (lhs, rhs) {
                case let (.movie(movie1), .movie(movie2)):
                    return movie1 == movie2
                case let (.episode(episode1), .episode(episode2)):
                    return episode1 == episode2
                default:
                    return false
                }
            }
        }

        let id: String
        let date: Date
        let group: ChartGroupType
        let dataType: DataType
    }

    struct GridListData: Identifiable, Equatable {
        enum DataType {
            case movie(Movie)
            case show(TVShow)
        }

        let item: DataType

        init(_ item: DataType) {
            self.item = item
        }

        var id: String {
            switch item {
            case let .movie(movie): return movie.id
            case let .show(show): return show.id
            }
        }

        var date: Date {
            switch item {
            case let .movie(movie): return movie.lastWatched
            case let .show(show): return show.episodes.map(\.lastWatched).max() ?? show.lastWatched
            }
        }

        var image: String {
            switch item {
            case let .movie(movie): return movie.image
            case let .show(show): return show.image
            }
        }

        var title: String {
            switch item {
            case let .movie(movie): return movie.title
            case let .show(show): return show.title
            }
        }

        var imageURL: URL? {
            switch item {
            case let .movie(movie): return movie.imageURL
            case let .show(show): return show.imageURL
            }
        }

        var subtitle: String {
            switch item {
            case let .movie(movie): return movie.lastWatched.formatted(date: .abbreviated, time: .omitted)
            case let .show(show): return show.episodes.count == 1 ? "\(show.episodes.count) episode" : "\(show.episodes.count) episodes"
            }
        }

        var asMedia: Media {
            switch item {
            case let .movie(movie): return movie
            case let .show(show): return show
            }
        }

        static func == (lhs: GridListData, rhs: GridListData) -> Bool {
            switch (lhs.item, rhs.item) {
            case let (.movie(movie1), .movie(movie2)):
                return movie1 == movie2
            case let (.show(show1), .show(show2)):
                return show1 == show2
            default:
                return false
            }
        }
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
