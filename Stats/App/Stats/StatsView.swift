//
//  StatsView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import Charts

struct StatsView: View {

    let data: [(month: Date, sales: Int)] = [
        (Date.now, 12),
        (Calendar.current.date(byAdding: .month, value: -1, to: Date.now)!, 10),
        (Calendar.current.date(byAdding: .month, value: -2, to: Date.now)!, 11),
        (Calendar.current.date(byAdding: .month, value: -3, to: Date.now)!, 9),
        (Calendar.current.date(byAdding: .month, value: -4, to: Date.now)!, 8),
        (Calendar.current.date(byAdding: .month, value: -5, to: Date.now)!, 13),
        (Calendar.current.date(byAdding: .month, value: -6, to: Date.now)!, 10)
    ]

    var body: some View {
        Chart(data, id: \.month) {
              BarMark(
                x: .value("Month", $0.month, unit: .month),
                y: .value("Sales", $0.sales)
              )
              .foregroundStyle(.green.gradient)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month))
        }
        .padding()
        .frame(height: 300)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
