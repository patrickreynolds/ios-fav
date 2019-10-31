import UIKit

import Cartography
import GooglePlaces

protocol AddEntryOnboardingStepViewDelegate {
    func didSelectItem(placeId: String, completion: @escaping () -> ())
}

class AddEntryOnboardingStepView: UIView {

    // MARK: - Properties

    let placesClient = GMSPlacesClient.init()
    private let step: OnboardingStepType
    var list: List?
    var delegate: OnboardingViewControllerDelegate? {
        didSet {
            if let delegate = delegate {
                constrain(resultsTableView, tableTitleLabel, self) { tableView, label, view in
                    tableView.bottom == view.bottom - delegate.keyboardHeight
                }
            }
        }
    }

    var addEntryDelegate: AddEntryOnboardingStepViewDelegate?


    private var results: [GMSAutocompletePrediction] = [] {
        didSet {
            resultsLoadingIndicator.stopAnimating()
            resultsTableView.reloadData()
        }
    }

    private var searchInput: String = "" {
        didSet {
            if !searchInput.isEmpty {
                tableTitleLabel.alpha = 1
            }

            if !searchInput.isEmpty {
                resultsLoadingIndicator.startAnimating()
            }

            updateSearchResultsWithQuery(query: searchInput)
        }
    }


    // MARK: - UI Properties

    private lazy var entryNameTextFieldView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.White
        view.layer.borderColor = FaveColors.Black30.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true

        view.addSubview(entryNameTextField)
        view.addSubview(entryNameSearchIconImageView)

        constrain(entryNameTextField, entryNameSearchIconImageView, view) { textField, imageView, view in
            imageView.top == view.top + 16
            imageView.bottom == view.bottom - 16
            imageView.left == view.left + 16

            textField.right == view.right - 16
            textField.left == imageView.right + 8
            textField.centerY == imageView.centerY
        }

        return view
    }()

    private lazy var entryNameTextField: UITextField = {
        let textField = UITextField.init(frame: .zero)

        textField.placeholder = "Search"
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .no
        textField.tintColor = FaveColors.HJCerulean
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        return textField
    }()

    private lazy var entryNameSearchIconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        imageView.image = UIImage(named: "tab-icon-search")
        imageView.tintColor = FaveColors.Black90

        constrain(imageView) { imageView in
            imageView.width == 24
            imageView.height == 24
        }

        return imageView
    }()

    private lazy var tableTitleLabel: Label = {
        let label = Label(
            text: "Results",
            font: FaveFont(style: .small, weight: .semiBold),
            textColor: FaveColors.Black90,
            textAlignment: .left,
            numberOfLines: 1)

        label.alpha = 0

        return label
    }()

    private lazy var resultsLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)

        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var resultsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(OnboardingGoogleSearchViewCell.self)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()


    // MARK: - Initializers

    init(step: OnboardingStepType) {
        self.step = step

        super.init(frame: .zero)

        addSubview(entryNameTextFieldView)
        addSubview(tableTitleLabel)
        addSubview(resultsLoadingIndicator)
        addSubview(resultsTableView)

        constrain(self) { view in
            view.width == UIScreen.main.bounds.width
        }

        constrain(entryNameTextFieldView, self) { textField, view in
            textField.top == view.top + 8
            textField.right == view.right - 16
            textField.left == view.left + 16
        }

        constrain(tableTitleLabel, entryNameTextFieldView, self) { label, textField, view in
            label.top == textField.bottom + 16
            label.left == view.left + 16
        }

        constrain(resultsLoadingIndicator, tableTitleLabel, self) { loadingIndicator, label, view in
            loadingIndicator.left == label.right + 8
            loadingIndicator.centerY == label.centerY
        }

        constrain(resultsTableView, tableTitleLabel, self) { tableView, label, view in
            tableView.top == label.bottom + 8
            tableView.right == view.right - 16
            tableView.left == view.left + 16

            if let delegate = delegate {
                tableView.bottom == view.bottom - delegate.keyboardHeight
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private Methods




    // MARK: - Public Methods

    @objc func textFieldDidChange(textField: UITextField!) {
        searchInput = textField.text ?? ""
    }

    func makeAddEntryFirstResponder() {
        entryNameTextField.becomeFirstResponder()
    }

    private func updateSearchResultsWithQuery(query: String) {

        let token = GMSAutocompleteSessionToken.init()

        // Create a type filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment

        placesClient.findAutocompletePredictions(fromQuery: query, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, sessionToken: token, callback: { (results, error) in
            if let error = error {
                print("Autocomplete error: \(error)")
                return
            }
            if let results = results {
                self.results = results
            }
        })
    }
}


extension AddEntryOnboardingStepView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]

        if let row = tableView.cellForRow(at: indexPath) as? OnboardingGoogleSearchViewCell {
            row.addButtonTapped()
            row.performImpact(style: .light)
        }

        addEntryDelegate?.didSelectItem(placeId: result.placeID) {
            self.delegate?.didAdvanceOnboarding()
            self.entryNameTextField.resignFirstResponder()
        }
    }
}

extension AddEntryOnboardingStepView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results.count > 3 {
            return 3
        }

        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(OnboardingGoogleSearchViewCell.self, indexPath: indexPath)

        let prediction = results[indexPath.row]

        cell.populate(prediction: prediction)

        return cell
    }
}

extension AddEntryOnboardingStepView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        entryNameTextField.resignFirstResponder()
    }
}
