
class TPricingCalculator {

  /// -- Calculate Price based on tax and Shipping

  static double calculateTotalPrice(double productPrice, String location){
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;

    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice + taxAmount + shippingCost;
    return totalPrice;
  }

  /// -- Calculating Shipping Cost

  static String calculateShipppingCost(double productPrice, String location){
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }

  /// --Calculating Tax

  static String calculateTax(double productPrice, String location){
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  static double getTaxRateForLocation(String location){
    // Lookup the atx rate for the given location from a tax rate database or API.
    // Return the Appropriate tax Rate.
    return 0.10;  // example tax rate of 10%
  }

  static double getShippingCost(String location){
    // Lookup the atx rate for the given location using a shipping rate API.
    // Calculate the Shipping cost based on various factors like distance, weight, etc.
    return 5.00;  // example shipping rate of 5$
  }

  /// -- Sum All cart values and return total Amount
//  static double calculateCartTotal(CartModel cart){
//    return cart.items.map((e) => e.price).fold(0, (previousPrice, CurrentPrice) => previousPrice + (currentPrice?? 0));
// }
}