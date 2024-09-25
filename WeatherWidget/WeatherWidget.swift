//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Ichsan Indra Wahyudi on 04/09/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

func loadWeatherFromUserDefault() -> WeatherData? {
    let userDefault = UserDefaults(suiteName: Constant.appGroup)
    
    guard let data = userDefault?.data(forKey: Constant.weatherDataKey),
          let decodedData = try? JSONDecoder().decode(WeatherData.self, from: data)
    else {
        return nil
    }
    
    return decodedData
}

func loadImageFromUserDefault() -> UIImage? {
    let userDefault = UserDefaults(suiteName: Constant.appGroup)
    
    guard let imageData = userDefault?.data(forKey: Constant.backgroundImageKey),
          let image = UIImage(data: imageData)
    else {
        return nil
    }
    
    return image
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @State private var image: UIImage? = nil
    @State private var data: WeatherData? = nil

    var body: some View {
        VStack (
            alignment: widgetFamily == .systemMedium ? .leading : .center,
            spacing: widgetFamily == .systemLarge ? 42 : 10
        ) {
            if let data {
                if let weather = data.weather.first,
                   let image = weather.type.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: imageSize().width, height: imageSize().height)
                        .containerRelativeFrame(.horizontal)
                }
                
                Text(data.name)
                    .foregroundStyle(image != nil ? .white : .black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .font(fontTextWidget())
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: widgetFamily == .systemMedium ? .leading : .center)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            } else {
                Text("Please Open The App First")
            }
        }
        .containerRelativeFrame(.horizontal)
        .containerRelativeFrame(.vertical)
        .background(
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
        )
        .onAppear {
            data = loadWeatherFromUserDefault()
            image = loadImageFromUserDefault()
        }
    }
    
    func imageSize() -> CGSize {
        switch widgetFamily {
        case .systemSmall:
            return CGSize.square(size: 67)
        case .systemMedium:
            return CGSize.square(size: 82)
        case .systemLarge, .systemExtraLarge:
            return CGSize.square(size: 155)
        default:
            return CGSize.square(size: 67)
        }
    }
    
    func fontTextWidget() -> Font {
        switch widgetFamily {
        case .systemSmall:
            return .system(size: 18)
        case .systemMedium:
            return .system(size: 22)
        case .systemLarge, .systemExtraLarge:
            return .system(size: 32)
        default:
            return .body
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
