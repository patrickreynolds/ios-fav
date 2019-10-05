import UIKit
import MapKit

import Cartography

protocol ItemMapTableViewCellDelegate {
    func didSelectMap(item: Item)
}

class ItemMapTableViewCell: UITableViewCell {

    var item: Item?
    var delegate: ItemMapTableViewCellDelegate?

    private lazy var titleLabel: Label = {
        let label = Label(text: "Map",
                          font: FaveFont(style: .h4, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var titleLabelView: UIView = {
        let view = UIView(frame: .zero)

        view.addSubview(titleLabel)

        constrain(titleLabel, view) { label, view in
            label.top == view.top + 16
            label.left == view.left + 16
            label.right == view.right - 16
            label.bottom == view.bottom - 16
        }

        return view
    }()

    private lazy var addressLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var directionsLabel: Label = {
        let label = Label(text: "Get directions",
                          font: FaveFont(style: .h5, weight: .semiBold),
                          textColor: FaveColors.Accent,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)

        constrain(mapView) { mapView in
            mapView.height == 160
        }

        _ = mapView.tapped { _ in
            self.handleMapTapped()
        }

        return mapView
    }()

    private lazy var addressView: UIView = {
        let view = UIView(frame: .zero)

        view.addSubview(addressLabel)

        constrain(addressLabel, view) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.bottom == view.bottom - 16
            label.left == view.left + 16
        }

        return view
    }()

    private lazy var directionsView: UIView = {
        let view = UIView(frame: .zero)

        view.addSubview(directionsLabel)

        constrain(directionsLabel, view) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.bottom == view.bottom - 16
            label.left == view.left + 16
        }

        _ = view.tapped { _ in
            self.getDirectionsTapped()
        }

        view.isUserInteractionEnabled = true

        return view
    }()

    private lazy var middleDividerView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 1
        }

        return view
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 8
        }

        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.addArrangedSubview(titleLabelView)
        stackView.addArrangedSubview(mapView)
        stackView.addArrangedSubview(addressView)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0

        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(contentStackView)
        contentView.addSubview(middleDividerView)
        contentView.addSubview(directionsView)
        contentView.addSubview(dividerView)

        constrainToSuperview(contentStackView, exceptEdges: [.bottom])

        constrain(middleDividerView, contentStackView, contentView) { middleDividerView, contentStackView, view in
            middleDividerView.top == contentStackView.bottom
            middleDividerView.right == view.right
            middleDividerView.left == view.left
        }

        constrain(directionsView, middleDividerView, dividerView, contentView) { directionsView, middleDividerView, dividerView, contentView in
            directionsView.top == middleDividerView.bottom
            directionsView.right == contentView.right
            directionsView.bottom == dividerView.top
            directionsView.left == contentView.left
        }

        constrainToSuperview(dividerView, exceptEdges: [.top])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item) {
        self.item = item

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        addressLabel.text = googleItem.formattedAddress

        setupMap(withGoogleItem: googleItem)
    }

    func handleMapTapped() {
        guard let item = self.item, let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: googleItem.geometry.latitude, longitude: googleItem.geometry.longitude)))
        destination.name = googleItem.name

        // URL(string: "comgooglemaps://?center=\(Float(googleItem.geometry.latitude)),\(Float(googleItem.geometry.longitude))&daddr=\(Float(googleItem.geometry.latitude)),\(Float(googleItem.geometry.longitude))&directionsmode=driving")

        if let _ = URL(string:"comgooglemaps://"),
            let locationURL = URL(string: "comgooglemaps://?center=\(Float(googleItem.geometry.latitude)),\(Float(googleItem.geometry.longitude))&daddr=\(googleItem.name),\(googleItem.formattedAddress)&directionsmode=driving") {
            UIApplication.shared.open(locationURL, options: [:], completionHandler: nil)
        } else {
            MKMapItem.openMaps(with: [destination], launchOptions: nil)
        }
    }

    func getDirectionsTapped() {
        guard let item = self.item, let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

//        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)))
//        source.name = "Here"

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: googleItem.geometry.latitude, longitude: googleItem.geometry.longitude)))
        destination.name = googleItem.name

        MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    func setupMap(withGoogleItem item: GoogleItemType) {
        let initialLocation = CLLocation(latitude: item.geometry.latitude, longitude: item.geometry.longitude)
        let regionRadius: CLLocationDistance = 1200

        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        let annotation = MKPointAnnotation()
        annotation.title = item.name
        annotation.coordinate = initialLocation.coordinate
        mapView.addAnnotation(annotation)

        mapView.setRegion(coordinateRegion, animated: true)

//        mapView.isUserInteractionEnabled = false
    }
}
