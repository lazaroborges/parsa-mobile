//
//  FinancialSummaryLiveActivity.swift
//  FinancialSummary
//
//  Created by Vitor Caetano on 20/05/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FinancialSummaryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FinancialSummaryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FinancialSummaryAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FinancialSummaryAttributes {
    fileprivate static var preview: FinancialSummaryAttributes {
        FinancialSummaryAttributes(name: "World")
    }
}

extension FinancialSummaryAttributes.ContentState {
    fileprivate static var smiley: FinancialSummaryAttributes.ContentState {
        FinancialSummaryAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FinancialSummaryAttributes.ContentState {
         FinancialSummaryAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FinancialSummaryAttributes.preview) {
   FinancialSummaryLiveActivity()
} contentStates: {
    FinancialSummaryAttributes.ContentState.smiley
    FinancialSummaryAttributes.ContentState.starEyes
}
