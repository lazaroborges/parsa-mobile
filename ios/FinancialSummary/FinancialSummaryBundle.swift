//
//  FinancialSummaryBundle.swift
//  FinancialSummary
//
//  Created by Vitor Caetano on 20/05/25.
//

import WidgetKit
import SwiftUI

@main
struct FinancialSummaryBundle: WidgetBundle {
    var body: some Widget {
        FinancialSummary()
        FinancialSummaryControl()
        FinancialSummaryLiveActivity()
    }
}
