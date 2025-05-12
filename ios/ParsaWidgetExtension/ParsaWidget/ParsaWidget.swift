import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), availableBalance: 0.0, income: 0.0, expense: 0.0, currency: "R$")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline with a single entry that refreshes in 30 minutes
        let currentDate = Date()
        let entry = getEntry()
        entries.append(entry)
        
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func getEntry() -> SimpleEntry {
        // Get shared data from App Group UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.parsa.app")
        
        let availableBalance = sharedDefaults?.double(forKey: "availableBalance") ?? 0.0
        let income = sharedDefaults?.double(forKey: "income") ?? 0.0
        let expense = sharedDefaults?.double(forKey: "expense") ?? 0.0
        let currency = sharedDefaults?.string(forKey: "currency") ?? "R$"
        
        return SimpleEntry(
            date: Date(),
            availableBalance: availableBalance,
            income: income,
            expense: expense,
            currency: currency
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let availableBalance: Double
    let income: Double
    let expense: Double
    let currency: String
}

struct ParsaWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: 0x1c64f2), Color(hex: 0x1724c9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Text("Parsa Finance")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Image(systemName: "p.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                // Balance Section
                VStack(alignment: .leading, spacing: 2) {
                    Text("Saldo Disponível")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(entry.currency) \(formatCurrency(entry.availableBalance))")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Income/Expense Section
                HStack(spacing: 12) {
                    // Income
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Receitas")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(entry.currency) \(formatCurrency(entry.income))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.green.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Expense
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Despesas")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(entry.currency) \(formatCurrency(entry.expense))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.red.opacity(0.9))
                    }
                }
            }
            .padding(16)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "pt_BR")
        
        return formatter.string(from: NSNumber(value: value)) ?? "0,00"
    }
}

struct ParsaWidget: Widget {
    let kind: String = "ParsaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ParsaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Parsa Finances")
        .description("Acompanhe seu saldo, receitas e despesas.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ParsaWidget_Previews: PreviewProvider {
    static var previews: some View {
        ParsaWidgetEntryView(entry: SimpleEntry(date: Date(), availableBalance: 2500.75, income: 5000.00, expense: 2750.25, currency: "R$"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ParsaWidgetEntryView(entry: SimpleEntry(date: Date(), availableBalance: 2500.75, income: 5000.00, expense: 2750.25, currency: "R$"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// Helper extension to create Color from hex
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
} 