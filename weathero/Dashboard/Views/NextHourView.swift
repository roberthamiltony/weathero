//
//  NextHourView.swift
//  weathero
//
//  Created by Robert Hamilton on 13/11/2022.
//

import Foundation
import UIKit
import SwiftUI
import Charts

struct MinutePrecipitationData: Identifiable {
    var id: Int { offset }
    var precipitation: Float
    var offset: Int
}

class NextHourView: UIView {
    let title: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 24.0, weight: .bold)
        title.textColor = .label
        title.text = "Next Hour"
        title.textAlignment = .left
        return title
    }()
    
    let graphView: UIHostingController<NextHourGraph>
    
    init(weatherManager: WeatherManager) {
        graphView = UIHostingController(rootView: NextHourGraph(weatherManager: weatherManager))
        super.init(frame: .zero)
        graphView.sizingOptions =  [.intrinsicContentSize]
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(title)
        addSubview(graphView.view)
    }
    
    private func setupConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(8)
            make.left.right.equalTo(safeAreaLayoutGuide).inset(16)
        }
        graphView.view.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.left.right.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
}

struct NextHourGraph: View {
    @ObservedObject var weatherManager: WeatherManager
    var body: some View {
        VStack {
            switch weatherManager.nextHourData {
            case .success(let minutes):
                GraphView(minutes: minutes)
            case .failure:
                Button("Retry") { [weatherManager] in
                    weatherManager.getData(dataSets: [.forecastNextHour])
                }
                .frame(height: 100)
            case .none:
                ProgressView()
                    .frame(height: 100)
            }
        }
    }
    
    private struct GraphView: View {
        var minutes: [MinutePrecipitationData]?
        var body: some View {
            if let minutes, minutes.first(where: { $0.precipitation > 0.0 }) != nil {
                let lineColour = Color.fromHex(red: 52.0, green: 140.0, blue: 235.0)
                let areaColour = LinearGradient(
                    gradient: Gradient (
                        colors: [
                            lineColour.opacity(0.5),
                            lineColour.opacity(0.2),
                            lineColour.opacity(0.05),
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                Chart {
                    ForEach(minutes) { minute in
                        LineMark(x: .value("Minute", minute.offset), y: .value("Precipitation", minute.precipitation))
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(lineColour)
                        AreaMark(x: .value("Minute", minute.offset), y: .value("Precipitation", minute.precipitation))
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(areaColour)
                    }
                }
                .chartXScale(domain: 0...59)
                .chartYScale(domain: WeatherClassifications.rainChartScale)
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .frame(height: 200)
            } else {
                Text("No precipitation for the next hour")
                    .font(.title3)
                    .foregroundColor(.init(UIColor.label))
                    .frame(height: 100)
            }
        }
    }
}

