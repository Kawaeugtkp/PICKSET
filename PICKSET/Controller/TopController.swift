////
////  TopController.swift
////  PICKSET
////
////  Created by 川尻辰義 on 2022/10/29.
////
//
//import UIKit
//import GoogleMobileAds
//
//let adCell = "adCell"
//
//class TopController: UICollectionViewController {
//    
//    // MARK: - Properties
//    
//    var adLoader: GADAdLoader!
//    
//    var heightConstraint: NSLayoutConstraint?
//    
//    var nativeAdView: GADNativeAdView!
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//    }
//    
//    // MARK: - Helpers
//    
//    func configureUI() {
//        view.backgroundColor = .purple
//        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511",
//            rootViewController: self,
//            adTypes: [ .native ],
//            options: nil)
//        adLoader.delegate = self
//        adLoader.load(GADRequest())
//        
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: adCell)
//    }
//    
//    func setAdView(_ view: GADNativeAdView, cell: UICollectionViewCell) {
//      // Remove the previous ad view.
//      nativeAdView = view
//      cell.addSubview(nativeAdView)
//      nativeAdView.translatesAutoresizingMaskIntoConstraints = false
//
//      // Layout constraints for positioning the native ad view to stretch the entire width and height
//      // of the nativeAdPlaceholder.
//      let viewDictionary = ["_nativeAdView": nativeAdView!]
//      self.view.addConstraints(
//        NSLayoutConstraint.constraints(
//          withVisualFormat: "H:|[_nativeAdView]|",
//          options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
//      )
//      self.view.addConstraints(
//        NSLayoutConstraint.constraints(
//          withVisualFormat: "V:|[_nativeAdView]|",
//          options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
//      )
//    }
//    
//    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
//      guard let rating = starRating?.doubleValue else {
//        return nil
//      }
//      if rating >= 5 {
//        return UIImage(named: "stars_5")
//      } else if rating >= 4.5 {
//        return UIImage(named: "stars_4_5")
//      } else if rating >= 4 {
//        return UIImage(named: "stars_4")
//      } else if rating >= 3.5 {
//        return UIImage(named: "stars_3_5")
//      } else {
//        return nil
//      }
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//
//extension TopController {
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: adCell, for: indexPath)
//        cell.backgroundColor = .black
//        guard
//          let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
//          let adView = nibObjects.first as? GADNativeAdView
//        else {
//          assert(false, "Could not load nib file for adView")
//        }
//        setAdView(adView, cell: cell)
//        return cell
//    }
//}
//
//// MARK: - GADAdLoaderDelegate
//
//extension TopController: GADNativeAdLoaderDelegate {
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
//        print("DEBUG: didFailToReceiveAdWithError \(error)")
//    }
//    
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
//        // Set ourselves as the native ad delegate to be notified of native ad events.
//        nativeAd.delegate = self
//
//        // Deactivate the height constraint that was set when the previous video ad loaded.
//        heightConstraint?.isActive = false
//
//        // Populate the native ad view with the native ad assets.
//        // The headline and mediaContent are guaranteed to be present in every native ad.
//        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
//        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
//
//        // Some native ads will include a video asset, while others do not. Apps can use the
//        // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
//        // UI accordingly.
//
//        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
//        // ratio of the media it displays.
//        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
//          heightConstraint = NSLayoutConstraint(
//            item: mediaView,
//            attribute: .height,
//            relatedBy: .equal,
//            toItem: mediaView,
//            attribute: .width,
//            multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
//            constant: 0)
//          heightConstraint?.isActive = true
//        }
//
//        // These assets are not guaranteed to be present. Check that they are before
//        // showing or hiding them.
//        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
//        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
//
//        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
//        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
//
//        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
//        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
//
//        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
//        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
//
//        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
//        nativeAdView.storeView?.isHidden = nativeAd.store == nil
//
//        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
//        nativeAdView.priceView?.isHidden = nativeAd.price == nil
//
//        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
//        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
//
//        // In order for the SDK to process touch events properly, user interaction should be disabled.
//        nativeAdView.callToActionView?.isUserInteractionEnabled = false
//
//        // Associate the native ad view with the native ad object. This is
//        // required to make the ad clickable.
//        // Note: this should always be done after populating the ad views.
//        nativeAdView.nativeAd = nativeAd
//    }
//}
//
//extension TopController: GADNativeAdDelegate {
//    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
//      // The native ad was shown.
//    }
//
//    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
//      // The native ad was clicked on.
//    }
//
//    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
//      // The native ad will present a full screen view.
//    }
//
//    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
//      // The native ad will dismiss a full screen view.
//    }
//
//    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
//      // The native ad did dismiss a full screen view.
//    }
//
//    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
//      // The native ad will cause the application to become inactive and
//      // open a new application.
//    }
//}
