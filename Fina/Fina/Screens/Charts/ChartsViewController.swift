//
//  ChartsViewController.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import UIKit
import RxCocoa
import Charts

final class ChartCell: UITableViewCell {
    
    var chart: ChartModel? {
        didSet {
            guard let chart = chart else { return }
            let incomeDataEntries = chart.incomeChartDataEntries()
            let outcomeDataEntries = chart.outcomeChartDataEntries()
            let incomeDataSet = BarChartDataSet(entries: incomeDataEntries)
            incomeDataSet.colors = [.green]
            incomeDataSet.label = "Income"
            let outcomeDataSet = BarChartDataSet(entries: outcomeDataEntries)
            outcomeDataSet.colors = [.red]
            outcomeDataSet.label = "Outcome"
            let data = BarChartData(dataSets: [incomeDataSet, outcomeDataSet])
            chartView.data = data
            chartView.drawGridBackgroundEnabled = false
            chartView.xAxis.drawAxisLineEnabled = false
            chartView.rightAxis.enabled = false
            chartView.scaleXEnabled = false
            chartView.xAxis.drawGridLinesEnabled = false
            chartView.leftYAxisRenderer.axis.drawGridLinesEnabled = false
            chartView.rightYAxisRenderer.axis.drawGridLinesEnabled = false
            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ChartModel.months)
            chartView.xAxis.drawLabelsEnabled = true
            chartView.scaleXEnabled = false
            chartView.autoScaleMinMaxEnabled = false
            chartAccount.text = "\(chart.bankAccount) (\(chart.currency.rawValue))"
        }
    }
    
    @IBOutlet private weak var chartView: BarChartView!
    @IBOutlet private weak var chartAccount: UILabel!
    
    class var cellReuseIdentifier: String {
        "ChartCell"
    }
}


final class ChartsViewController: BaseViewController {
    
    private var viewModel: ChartsViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func configure() {
        super.configure()
        
        viewModel = ChartsViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.fetch()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.chartsRelay.asDriver().drive(tableView.rx.items(cellIdentifier: ChartCell.cellReuseIdentifier, cellType: ChartCell.self)) { row, item, cell in
            cell.chart = item
        }.disposed(by: disposeBag)
    }

}
