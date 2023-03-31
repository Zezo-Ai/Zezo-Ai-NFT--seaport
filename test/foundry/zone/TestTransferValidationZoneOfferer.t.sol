// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// import { BaseOrderTest } from "../utils/BaseOrderTest.sol";

// import {
//     AdvancedOrder,
//     ConsiderationItem,
//     CriteriaResolver,
//     Fulfillment,
//     FulfillmentComponent,
//     ItemType,
//     SpentItem,
//     OfferItem,
//     Order,
//     OrderComponents,
//     OrderParameters,
//     OrderType,
//     ReceivedItem,
//     ZoneParameters
// } from "../../../contracts/lib/ConsiderationStructs.sol";

// import { TestERC721Revert } from "../../../contracts/test/TestERC721Revert.sol";

// import {
//     ConsiderationInterface
// } from "../../../contracts/interfaces/ConsiderationInterface.sol";

// import { ZoneInterface } from "../../../contracts/interfaces/ZoneInterface.sol";

// import {
//     ContractOffererInterface
// } from "../../../contracts/interfaces/ContractOffererInterface.sol";

// import {
//     ConsiderationItemLib,
//     FulfillmentComponentLib,
//     FulfillmentLib,
//     OfferItemLib,
//     OrderComponentsLib,
//     OrderParametersLib,
//     OrderLib,
//     SeaportArrays,
//     ZoneParametersLib
// } from "../../../contracts/helpers/sol/lib/SeaportStructLib.sol";

// import {
//     TestTransferValidationZoneOfferer
// } from "../../../contracts/test/TestTransferValidationZoneOfferer.sol";

// import {
//     TestCalldataHashContractOfferer
// } from "../../../contracts/test/TestCalldataHashContractOfferer.sol";

// import {
//     FulfillAvailableHelper
// } from "seaport-sol/fulfillments/available/FulfillAvailableHelper.sol";

// import {
//     MatchFulfillmentHelper
// } from "seaport-sol/fulfillments/match/MatchFulfillmentHelper.sol";

// import { TestZone } from "./impl/TestZone.sol";

// contract TestTransferValidationZoneOffererTest is BaseOrderTest {
//     using FulfillmentLib for Fulfillment;
//     using FulfillmentComponentLib for FulfillmentComponent;
//     using FulfillmentComponentLib for FulfillmentComponent[];
//     using OfferItemLib for OfferItem;
//     using OfferItemLib for OfferItem[];
//     using ConsiderationItemLib for ConsiderationItem;
//     using ConsiderationItemLib for ConsiderationItem[];
//     using OrderComponentsLib for OrderComponents;
//     using OrderParametersLib for OrderParameters;
//     using OrderLib for Order;
//     using OrderLib for Order[];
//     using ZoneParametersLib for AdvancedOrder[];

//     MatchFulfillmentHelper matchFulfillmentHelper;
//     TestTransferValidationZoneOfferer zone;
//     TestZone testZone;

//     // constant strings for recalling struct lib defaults
//     // ideally these live in a base test class
//     string constant ONE_ETH = "one eth";
//     string constant THREE_ERC20 = "three erc20";
//     string constant SINGLE_721 = "single 721";
//     string constant VALIDATION_ZONE = "validation zone";
//     string constant CONTRACT_ORDER = "contract order";

//     event ValidateOrderDataHash(bytes32 dataHash);
//     event GenerateOrderDataHash(bytes32 orderHash, bytes32 dataHash);
//     event RatifyOrderDataHash(bytes32 orderHash, bytes32 dataHash);

//     function setUp() public virtual override {
//         super.setUp();
//         matchFulfillmentHelper = new MatchFulfillmentHelper();
//         zone = new TestTransferValidationZoneOfferer(address(0));
//         testZone = new TestZone();

//         // create a default considerationItem for one ether;
//         // note that it does not have recipient set
//         ConsiderationItemLib
//         .empty()
//         .withItemType(ItemType.NATIVE)
//         .withToken(address(0)) // not strictly necessary
//             .withStartAmount(1 ether)
//             .withEndAmount(1 ether)
//             .withIdentifierOrCriteria(0)
//             .saveDefault(ONE_ETH); // not strictly necessary

//         // create a default offerItem for one ether;
//         // note that it does not have recipient set
//         OfferItemLib
//         .empty()
//         .withItemType(ItemType.NATIVE)
//         .withToken(address(0)) // not strictly necessary
//             .withStartAmount(1 ether)
//             .withEndAmount(1 ether)
//             .withIdentifierOrCriteria(0)
//             .saveDefault(ONE_ETH); // not strictly necessary

//         // create a default consideration for a single 721;
//         // note that it does not have recipient, token or
//         // identifier set
//         ConsiderationItemLib
//             .empty()
//             .withItemType(ItemType.ERC721)
//             .withStartAmount(1)
//             .withEndAmount(1)
//             .saveDefault(SINGLE_721);

//         // create a default considerationItem for three erc20;
//         // note that it does not have recipient set
//         ConsiderationItemLib
//             .empty()
//             .withItemType(ItemType.ERC20)
//             .withStartAmount(3 ether)
//             .withEndAmount(3 ether)
//             .withIdentifierOrCriteria(0)
//             .saveDefault(THREE_ERC20); // not strictly necessary

//         // create a default offerItem for a single 721;
//         // note that it does not have token or identifier set
//         OfferItemLib
//             .empty()
//             .withItemType(ItemType.ERC721)
//             .withStartAmount(1)
//             .withEndAmount(1)
//             .saveDefault(SINGLE_721);

//         OrderComponentsLib
//         .empty()
//         .withOfferer(offerer1.addr)
//         .withZone(address(zone))
//         // fill in offer later
//         // fill in consideration later
//         .withOrderType(OrderType.FULL_RESTRICTED)
//         .withStartTime(block.timestamp)
//         .withEndTime(block.timestamp + 1)
//         .withZoneHash(bytes32(0)) // not strictly necessary
//             .withSalt(0)
//             .withConduitKey(conduitKeyOne)
//             .saveDefault(VALIDATION_ZONE);
//         // fill in counter later

//         // create a default orderComponents for a contract order
//         OrderComponentsLib
//         .empty()
//         .withOrderType(OrderType.CONTRACT)
//         .withStartTime(block.timestamp)
//         .withEndTime(block.timestamp + 1)
//         .withZoneHash(bytes32(0)) // not strictly necessary
//             .withSalt(0)
//             .withConduitKey(conduitKeyOne)
//             .saveDefault(CONTRACT_ORDER);
//     }

//     struct Context {
//         ConsiderationInterface seaport;
//     }

//     function test(
//         function(Context memory) external fn,
//         Context memory context
//     ) internal {
//         try fn(context) {
//             fail("Expected revert");
//         } catch (bytes memory reason) {
//             assertPass(reason);
//         }
//     }

//     function testExecFulfillAvailableAdvancedOrdersWithConduitAndERC20()
//         public
//     {
//         prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20();
//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitAndERC20,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitAndERC20,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20()
//         internal
//     {
//         test721_1.mint(offerer1.addr, 42);
//         test721_1.mint(offerer1.addr, 43);
//     }

//     function execFulfillAvailableAdvancedOrdersWithConduitAndERC20(
//         Context memory context
//     ) external stateless {
//         // Set up an NFT recipient.
//         address considerationRecipientAddress = makeAddr(
//             "considerationRecipientAddress"
//         );

//         // This instance of the zone expects bob to be the recipient of all
//         // spent items (the ERC721s).
//         TestTransferValidationZoneOfferer transferValidationZone = new TestTransferValidationZoneOfferer(
//                 address(bob)
//             );

//         // Set up variables we'll use below the following block.
//         AdvancedOrder[] memory advancedOrders;

//         // Create a block to deal with stack depth issues.
//         {
//             OrderComponents memory orderComponentsOne;
//             OrderComponents memory orderComponentsTwo;

//             // Create the offer items for the first order.
//             OfferItem[] memory offerItemsOne = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(42)
//             );

//             // Create the consideration items for the first order.
//             ConsiderationItem[] memory considerationItemsOne = SeaportArrays
//                 .ConsiderationItems(
//                     ConsiderationItemLib
//                         .fromDefault(THREE_ERC20)
//                         .withToken(address(token1))
//                         .withRecipient(considerationRecipientAddress)
//                 );

//             // Create the order components for the first order.
//             orderComponentsOne = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsOne)
//                 .withConsideration(considerationItemsOne)
//                 .withZone(address(transferValidationZone));

//             // Create the offer items for the second order.
//             OfferItem[] memory offerItemsTwo = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(43)
//             );

//             // Create the order components for the second order using the same
//             // consideration items as the first order.
//             orderComponentsTwo = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsTwo)
//                 .withConsideration(considerationItemsOne)
//                 .withZone(address(transferValidationZone));

//             // Create the orders.
//             Order[] memory orders = _buildOrders(
//                 context,
//                 SeaportArrays.OrderComponentsArray(
//                     orderComponentsOne,
//                     orderComponentsTwo
//                 ),
//                 offerer1.key
//             );

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, "")
//             );
//         }

//         (
//             FulfillmentComponent[][] memory offerFulfillments,
//             FulfillmentComponent[][] memory considerationFulfillments
//         ) = fulfill.getAggregatedFulfillmentComponents(advancedOrders);

//         // Create the empty criteria resolvers.
//         CriteriaResolver[] memory criteriaResolvers;

//         // Make the call to Seaport.
//         context.seaport.fulfillAvailableAdvancedOrders({
//             advancedOrders: advancedOrders,
//             criteriaResolvers: criteriaResolvers,
//             offerFulfillments: offerFulfillments,
//             considerationFulfillments: considerationFulfillments,
//             fulfillerConduitKey: bytes32(conduitKeyOne),
//             recipient: address(bob),
//             maximumFulfilled: 2
//         });

//         assertTrue(transferValidationZone.called());
//         assertTrue(transferValidationZone.callCount() == 2);
//     }

//     function testExecFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipLast()
//         public
//     {
//         prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipLast();
//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipLast,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipLast,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipLast()
//         internal
//     {
//         test721_1.mint(offerer1.addr, 42);
//         test721_1.mint(offerer1.addr, 43);
//     }

//     function execFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipLast(
//         Context memory context
//     ) external stateless {
//         // Set up an NFT recipient.
//         address considerationRecipientAddress = makeAddr(
//             "considerationRecipientAddress"
//         );

//         // This instance of the zone expects bob to be the recipient of all
//         // spent items (the ERC721s).
//         TestTransferValidationZoneOfferer transferValidationZone = new TestTransferValidationZoneOfferer(
//                 address(0)
//             );

//         // Set up variables we'll use below the following block.
//         AdvancedOrder[] memory advancedOrders;

//         // Create a block to deal with stack depth issues.
//         {
//             OrderComponents memory orderComponentsOne;
//             OrderComponents memory orderComponentsTwo;

//             // Create the offer items for the first order.
//             OfferItem[] memory offerItemsOne = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(42)
//             );

//             // Create the consideration items for the first order.
//             ConsiderationItem[] memory considerationItemsOne = SeaportArrays
//                 .ConsiderationItems(
//                     ConsiderationItemLib
//                         .fromDefault(THREE_ERC20)
//                         .withToken(address(token1))
//                         .withRecipient(considerationRecipientAddress),
//                     ConsiderationItemLib
//                         .fromDefault(THREE_ERC20)
//                         .withToken(address(token1))
//                         .withStartAmount(5 ether)
//                         .withEndAmount(5 ether)
//                         .withRecipient(considerationRecipientAddress)
//                 );

//             // Create the order components for the first order.
//             orderComponentsOne = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsOne)
//                 .withConsideration(considerationItemsOne)
//                 .withZone(address(transferValidationZone));

//             // Create the offer items for the second order.
//             OfferItem[] memory offerItemsTwo = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(43)
//             );

//             // Create the consideration items for the second order.
//             ConsiderationItem[] memory considerationItemsTwo = SeaportArrays
//                 .ConsiderationItems(
//                     ConsiderationItemLib
//                         .fromDefault(THREE_ERC20)
//                         .withToken(address(token1))
//                         .withStartAmount(7 ether)
//                         .withEndAmount(7 ether)
//                         .withRecipient(considerationRecipientAddress),
//                     ConsiderationItemLib
//                         .fromDefault(THREE_ERC20)
//                         .withToken(address(token1))
//                         .withStartAmount(9 ether)
//                         .withEndAmount(9 ether)
//                         .withRecipient(considerationRecipientAddress)
//                 );

//             // Create the order components for the second order using the same
//             // consideration items as the first order.
//             orderComponentsTwo = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsTwo)
//                 .withConsideration(considerationItemsTwo)
//                 .withZone(address(transferValidationZone));

//             // Create the orders.
//             Order[] memory orders = _buildOrders(
//                 context,
//                 SeaportArrays.OrderComponentsArray(
//                     orderComponentsOne,
//                     orderComponentsTwo
//                 ),
//                 offerer1.key
//             );

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, "")
//             );
//         }

//         (
//             FulfillmentComponent[][] memory offerFulfillments,
//             FulfillmentComponent[][] memory considerationFulfillments
//         ) = fulfill.getAggregatedFulfillmentComponents(advancedOrders);

//         // Create the empty criteria resolvers.
//         CriteriaResolver[] memory criteriaResolvers;

//         {
//             // Get the zone parameters.
//             ZoneParameters[] memory zoneParameters = advancedOrders
//                 .getZoneParameters(
//                     address(this),
//                     advancedOrders.length - 1,
//                     address(context.seaport),
//                     new CriteriaResolver[](0)
//                 );

//             _emitZoneValidateOrderDataHashes(zoneParameters);
//         }

//         // Make the call to Seaport.
//         context.seaport.fulfillAvailableAdvancedOrders({
//             advancedOrders: advancedOrders,
//             criteriaResolvers: criteriaResolvers,
//             offerFulfillments: offerFulfillments,
//             considerationFulfillments: considerationFulfillments,
//             fulfillerConduitKey: bytes32(conduitKeyOne),
//             recipient: address(0),
//             maximumFulfilled: advancedOrders.length - 1
//         });
//     }

//     function testExecFulfillAvailableAdvancedOrdersWithConduitAndERC20Collision()
//         public
//     {
//         prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20Collision();
//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitAndERC20Collision,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitAndERC20Collision,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20Collision()
//         internal
//     {
//         test721_1.mint(offerer1.addr, 42);
//         test721_1.mint(offerer1.addr, 43);
//     }

//     function execFulfillAvailableAdvancedOrdersWithConduitAndERC20Collision(
//         Context memory context
//     ) external stateless {
//         string memory stranger = "stranger";
//         address strangerAddress = makeAddr(stranger);
//         uint256 strangerAddressUint = uint256(
//             uint160(address(strangerAddress))
//         );

//         // Make sure the fulfiller has enough to cover the consideration.
//         token1.mint(address(this), strangerAddressUint);

//         // Make the stranger rich enough that the balance check passes.
//         token1.mint(strangerAddress, strangerAddressUint);

//         // This instance of the zone expects offerer1 to be the recipient of all
//         // spent items (the ERC721s). This permits bypassing the ERC721 transfer
//         // checks, which would otherwise block the consideration transfer
//         // checks, which is the target to tinker with.
//         TestTransferValidationZoneOfferer transferValidationZone = new TestTransferValidationZoneOfferer(
//                 address(offerer1.addr)
//             );

//         // Set up variables we'll use below the following block.
//         AdvancedOrder[] memory advancedOrders;
//         FulfillmentComponent[][] memory offerFulfillments;
//         FulfillmentComponent[][] memory considerationFulfillments;

//         // Create a block to deal with stack depth issues.
//         {
//             OrderComponents memory orderComponentsOne;
//             OrderComponents memory orderComponentsTwo;

//             // Create the offer items for the first order.
//             OfferItem[] memory offerItemsOne = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(42)
//             );

//             // Create the consideration items for the first order.
//             ConsiderationItem[] memory considerationItemsOne = SeaportArrays
//                 .ConsiderationItems(
//                     ConsiderationItemLib
//                         .fromDefault(THREE_ERC20)
//                         .withToken(address(token1))
//                         .withStartAmount(10)
//                         .withEndAmount(10)
//                         .withRecipient(payable(offerer1.addr))
//                 );

//             // Create the order components for the first order.
//             orderComponentsOne = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsOne)
//                 .withConsideration(considerationItemsOne)
//                 .withZone(address(transferValidationZone));

//             // Create the offer items for the second order.
//             OfferItem[] memory offerItemsTwo = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(43)
//             );

//             // Create the order components for the second order using the same
//             // consideration items as the first order.
//             orderComponentsTwo = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsTwo)
//                 .withConsideration(considerationItemsOne)
//                 .withZone(address(transferValidationZone));

//             // Create the orders.
//             Order[] memory orders = _buildOrders(
//                 context,
//                 SeaportArrays.OrderComponentsArray(
//                     orderComponentsOne,
//                     orderComponentsTwo
//                 ),
//                 offerer1.key
//             );

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, "")
//             );

//             (offerFulfillments, considerationFulfillments) = fulfill
//                 .getAggregatedFulfillmentComponents(advancedOrders);
//         }

//         ZoneParameters[] memory zoneParameters = advancedOrders
//             .getZoneParameters(
//                 address(this),
//                 advancedOrders.length,
//                 address(context.seaport),
//                 new CriteriaResolver[](0)
//             );

//         bytes32[] memory payloadHashes = new bytes32[](zoneParameters.length);

//         for (uint256 i = 0; i < zoneParameters.length; i++) {
//             payloadHashes[i] = keccak256(
//                 abi.encodeCall(ZoneInterface.validateOrder, (zoneParameters[i]))
//             );

//             emit ValidateOrderDataHash(payloadHashes[i]);
//         }

//         // Make the call to Seaport.
//         context.seaport.fulfillAvailableAdvancedOrders({
//             advancedOrders: advancedOrders,
//             criteriaResolvers: new CriteriaResolver[](0),
//             offerFulfillments: offerFulfillments,
//             considerationFulfillments: considerationFulfillments,
//             fulfillerConduitKey: bytes32(conduitKeyOne),
//             recipient: address(offerer1.addr),
//             maximumFulfilled: advancedOrders.length
//         });
//     }

//     function testExecFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipMultiple()
//         public
//     {
//         prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipMultiple();
//         test(
//             this
//                 .execFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipMultiple,
//             Context({ seaport: consideration })
//         );
//         test(
//             this
//                 .execFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipMultiple,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function prepareFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipMultiple()
//         internal
//     {
//         test721_1.mint(offerer1.addr, 42);
//         test721_1.mint(offerer1.addr, 43);
//         test721_1.mint(offerer1.addr, 44);
//     }

//     function execFulfillAvailableAdvancedOrdersWithConduitAndERC20SkipMultiple(
//         Context memory context
//     ) external stateless {
//         // The idea here is to fulfill one, skinny through a second using the
//         // collision trick, and then see what happens on the third.
//         uint256 strangerAddressUint = uint256(
//             uint160(address(makeAddr("stranger")))
//         );

//         // Make sure the fulfiller has enough to cover the consideration.
//         token1.mint(address(this), strangerAddressUint * 3);

//         // Make the stranger rich enough that the balance check passes.
//         token1.mint(address(makeAddr("stranger")), strangerAddressUint);

//         // This instance of the zone expects offerer1 to be the recipient of all
//         // spent items (the ERC721s). This permits bypassing the ERC721 transfer
//         // checks, which would otherwise block the consideration transfer
//         // checks, which the the target to tinker with.
//         TestTransferValidationZoneOfferer transferValidationZone = new TestTransferValidationZoneOfferer(
//                 address(offerer1.addr)
//             );

//         // Set up variables we'll use below the following block.

//         AdvancedOrder[] memory advancedOrders;
//         FulfillmentComponent[][] memory offerFulfillments;
//         FulfillmentComponent[][] memory considerationFulfillments;

//         // Create a block to deal with stack depth issues.
//         {
//             OrderComponents memory orderComponentsOne;
//             OrderComponents memory orderComponentsTwo;
//             OrderComponents memory orderComponentsThree;
//             OfferItem[] memory offerItems;
//             ConsiderationItem[] memory considerationItems;

//             // Create the offer items for the first order.
//             offerItems = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(42)
//             );

//             // Create the consideration items for the first order.
//             considerationItems = SeaportArrays.ConsiderationItems(
//                 ConsiderationItemLib
//                     .fromDefault(THREE_ERC20)
//                     .withToken(address(token1))
//                     .withStartAmount(1 ether)
//                     .withEndAmount(1 ether)
//                     .withRecipient(payable(offerer1.addr))
//             );

//             // Create the order components for the first order.
//             orderComponentsOne = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItems)
//                 .withConsideration(considerationItems)
//                 .withZone(address(transferValidationZone));

//             // Create the offer items for the second order.
//             offerItems = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(43)
//             );

//             // Create the consideration items for the first order.
//             considerationItems = SeaportArrays.ConsiderationItems(
//                 ConsiderationItemLib
//                     .fromDefault(THREE_ERC20)
//                     .withToken(address(token1))
//                     .withStartAmount(strangerAddressUint)
//                     .withEndAmount(strangerAddressUint)
//                     .withRecipient(payable(offerer1.addr))
//             );

//             // Create the order components for the second order.
//             orderComponentsTwo = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItems)
//                 .withConsideration(considerationItems)
//                 .withZone(address(transferValidationZone));

//             // Create the offer items for the third order.
//             offerItems = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(44)
//             );

//             // Create the consideration items for the third order.
//             considerationItems = SeaportArrays.ConsiderationItems(
//                 ConsiderationItemLib
//                     .fromDefault(THREE_ERC20)
//                     .withToken(address(token1))
//                     .withStartAmount(3 ether)
//                     .withEndAmount(3 ether)
//                     .withRecipient(payable(offerer1.addr)) // Not necessary, but explicit
//             );

//             // Create the order components for the third order.
//             orderComponentsTwo = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItems)
//                 .withConsideration(considerationItems)
//                 .withZone(address(transferValidationZone));

//             // Create the orders.
//             Order[] memory orders = _buildOrders(
//                 context,
//                 SeaportArrays.OrderComponentsArray(
//                     orderComponentsOne,
//                     orderComponentsTwo,
//                     orderComponentsThree
//                 ),
//                 offerer1.key
//             );

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, ""),
//                 orders[2].toAdvancedOrder(1, 1, "")
//             );

//             (offerFulfillments, considerationFulfillments) = fulfill
//                 .getAggregatedFulfillmentComponents(advancedOrders);
//         }

//         {
//             // Get the zone parameters.
//             ZoneParameters[] memory zoneParameters = advancedOrders
//                 .getZoneParameters(
//                     address(this),
//                     1,
//                     address(context.seaport),
//                     new CriteriaResolver[](0)
//                 );

//             _emitZoneValidateOrderDataHashes(zoneParameters);
//         }

//         // Should not revert.
//         context.seaport.fulfillAvailableAdvancedOrders({
//             advancedOrders: advancedOrders,
//             criteriaResolvers: new CriteriaResolver[](0),
//             offerFulfillments: offerFulfillments,
//             considerationFulfillments: considerationFulfillments,
//             fulfillerConduitKey: bytes32(conduitKeyOne),
//             recipient: offerer1.addr,
//             maximumFulfilled: advancedOrders.length - 2
//         });
//     }

//     function testFulfillAvailableAdvancedOrdersWithConduitNativeAndERC20()
//         public
//     {
//         prepareFulfillAvailableAdvancedOrdersWithConduitNativeAndERC20();

//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitNativeAndERC20,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execFulfillAvailableAdvancedOrdersWithConduitNativeAndERC20,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function prepareFulfillAvailableAdvancedOrdersWithConduitNativeAndERC20()
//         internal
//     {
//         test721_1.mint(offerer1.addr, 42);
//         test721_1.mint(offerer1.addr, 43);
//     }

//     function execFulfillAvailableAdvancedOrdersWithConduitNativeAndERC20(
//         Context memory context
//     ) external stateless {
//         // Set up an NFT recipient.
//         address considerationRecipientAddress = makeAddr(
//             "considerationRecipientAddress"
//         );

//         // This instance of the zone expects the fulfiller to be the recipient
//         // recipient of all spent items.
//         TestTransferValidationZoneOfferer transferValidationZone = new TestTransferValidationZoneOfferer(
//                 address(0)
//             );

//         // Set up variables we'll use below the following block.
//         AdvancedOrder[] memory advancedOrders;

//         // Create a block to deal with stack depth issues.
//         {
//             OrderComponents memory orderComponentsOne;
//             OrderComponents memory orderComponentsTwo;

//             // Create the offer items for the first order.
//             OfferItem[] memory offerItemsOne = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(42)
//             );

//             // Create the consideration items for the first order.
//             ConsiderationItem[] memory considerationItemsOne = SeaportArrays
//                 .ConsiderationItems(
//                     ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                         considerationRecipientAddress
//                     ),
//                     ConsiderationItemLib
//                         .fromDefault(THREE_ERC20)
//                         .withToken(address(token1))
//                         .withRecipient(considerationRecipientAddress)
//                 );

//             // Create the order components for the first order.
//             orderComponentsOne = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsOne)
//                 .withConsideration(considerationItemsOne)
//                 .withZone(address(transferValidationZone));

//             // Create the offer items for the second order.
//             OfferItem[] memory offerItemsTwo = SeaportArrays.OfferItems(
//                 OfferItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_1))
//                     .withIdentifierOrCriteria(43)
//             );

//             // Create the order components for the second order.
//             orderComponentsTwo = OrderComponentsLib
//                 .fromDefault(VALIDATION_ZONE)
//                 .withOffer(offerItemsTwo)
//                 .withConsideration(considerationItemsOne)
//                 .withZone(address(transferValidationZone));

//             // Create the orders.
//             Order[] memory orders = _buildOrders(
//                 context,
//                 SeaportArrays.OrderComponentsArray(
//                     orderComponentsOne,
//                     orderComponentsTwo
//                 ),
//                 offerer1.key
//             );

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, "")
//             );
//         }

//         (
//             FulfillmentComponent[][] memory offerFulfillments,
//             FulfillmentComponent[][] memory considerationFulfillments
//         ) = fulfill.getAggregatedFulfillmentComponents(advancedOrders);

//         // Create the empty criteria resolvers.
//         CriteriaResolver[] memory criteriaResolvers;

//         // Get the zone parameters.
//         ZoneParameters[] memory zoneParameters = advancedOrders
//             .getZoneParameters(
//                 address(this),
//                 advancedOrders.length,
//                 address(context.seaport),
//                 new CriteriaResolver[](0)
//             );

//         _emitZoneValidateOrderDataHashes(zoneParameters);

//         // Make the call to Seaport.
//         context.seaport.fulfillAvailableAdvancedOrders{ value: 3 ether }({
//             advancedOrders: advancedOrders,
//             criteriaResolvers: criteriaResolvers,
//             offerFulfillments: offerFulfillments,
//             considerationFulfillments: considerationFulfillments,
//             fulfillerConduitKey: bytes32(conduitKeyOne),
//             recipient: address(0),
//             maximumFulfilled: 2
//         });
//     }

//     function testAggregate() public {
//         prepareAggregate();

//         test(this.execAggregate, Context({ seaport: consideration }));
//         test(this.execAggregate, Context({ seaport: referenceConsideration }));
//     }

//     ///@dev prepare aggregate test by minting tokens to offerer1
//     function prepareAggregate() internal {
//         test721_1.mint(offerer1.addr, 1);
//         test721_2.mint(offerer1.addr, 1);
//     }

//     function execAggregate(Context memory context) external stateless {
//         (
//             Order[] memory orders,
//             FulfillmentComponent[][] memory offerFulfillments,
//             FulfillmentComponent[][] memory considerationFulfillments,
//             bytes32 conduitKey,
//             uint256 numOrders
//         ) = _buildFulfillmentData(context);

//         context.seaport.fulfillAvailableOrders{ value: 2 ether }({
//             orders: orders,
//             offerFulfillments: offerFulfillments,
//             considerationFulfillments: considerationFulfillments,
//             fulfillerConduitKey: conduitKey,
//             maximumFulfilled: numOrders
//         });
//     }

//     function testMatchContractOrdersWithConduit() public {
//         test(
//             this.execMatchContractOrdersWithConduit,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execMatchContractOrdersWithConduit,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function execMatchContractOrdersWithConduit(
//         Context memory context
//     ) external stateless {
//         (
//             Order[] memory orders,
//             Fulfillment[] memory fulfillments,
//             ,

//         ) = _buildFulfillmentDataMirrorContractOrders(context);

//         context.seaport.matchOrders{ value: 1 ether }({
//             orders: orders,
//             fulfillments: fulfillments
//         });
//     }

//     function testExecMatchAdvancedContractOrdersWithConduit() public {
//         test(
//             this.execMatchAdvancedContractOrdersWithConduit,
//             Context({ seaport: consideration })
//         );
//         // test(
//         //     this.execMatchAdvancedContractOrdersWithConduit,
//         //     Context({ seaport: referenceConsideration })
//         // );
//     }

//     function execMatchAdvancedContractOrdersWithConduit(
//         Context memory context
//     ) external stateless {
//         (
//             Order[] memory orders,
//             Fulfillment[] memory fulfillments,
//             ,

//         ) = _buildFulfillmentDataMirrorContractOrders(context);

//         AdvancedOrder[] memory advancedOrders;

//         // Convert the orders to advanced orders.
//         advancedOrders = SeaportArrays.AdvancedOrders(
//             orders[0].toAdvancedOrder(1, 1, ""),
//             orders[1].toAdvancedOrder(1, 1, "")
//         );

//         {
//             bytes32[2][] memory orderHashes = _getOrderHashes(context, orders);
//             bytes32[2][]
//                 memory calldataHashes = _generateContractOrderDataHashes(
//                     context,
//                     orders
//                 );

//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 orders[0].parameters.offerer
//             );
//             emit GenerateOrderDataHash(orderHashes[0][0], calldataHashes[0][0]);

//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 orders[1].parameters.offerer
//             );
//             emit GenerateOrderDataHash(orderHashes[1][0], calldataHashes[1][0]);

//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 orders[0].parameters.offerer
//             );
//             emit RatifyOrderDataHash(orderHashes[0][1], calldataHashes[0][1]);

//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 orders[1].parameters.offerer
//             );
//             emit RatifyOrderDataHash(orderHashes[1][1], calldataHashes[1][1]);
//         }

//         CriteriaResolver[] memory criteriaResolvers = new CriteriaResolver[](0);

//         context.seaport.matchAdvancedOrders(
//             advancedOrders,
//             criteriaResolvers,
//             fulfillments,
//             address(0)
//         );
//     }

//     function testMatchOpenAndContractOrdersWithConduit() public {
//         test(
//             this.execMatchOpenAndContractOrdersWithConduit,
//             Context({ seaport: consideration })
//         );
//         // test(
//         //     this.execMatchOpenAndContractOrdersWithConduit,
//         //     Context({ seaport: referenceConsideration })
//         // );
//     }

//     function execMatchOpenAndContractOrdersWithConduit(
//         Context memory context
//     ) external stateless {
//         (
//             Order[] memory orders,
//             Fulfillment[] memory fulfillments,
//             ,

//         ) = _buildFulfillmentDataOpenOrderAndMirrorContractOrder(context);

//         bytes32[2][] memory orderHashes = _getOrderHashes(context, orders);
//         bytes32[2][] memory calldataHashes = _generateContractOrderDataHashes(
//             context,
//             orders
//         );

//         vm.expectEmit(true, false, false, true, orders[0].parameters.offerer);
//         emit GenerateOrderDataHash(orderHashes[0][0], calldataHashes[0][0]);

//         vm.expectEmit(true, false, false, true, orders[0].parameters.offerer);
//         emit RatifyOrderDataHash(orderHashes[0][1], calldataHashes[0][1]);

//         context.seaport.matchOrders{ value: 1 ether }({
//             orders: orders,
//             fulfillments: fulfillments
//         });
//     }

//     function testMatchFullRestrictedOrdersNoConduit() public {
//         test(
//             this.execMatchFullRestrictedOrdersNoConduit,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execMatchFullRestrictedOrdersNoConduit,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function execMatchFullRestrictedOrdersNoConduit(
//         Context memory context
//     ) external stateless {
//         // set offerer2 as the expected offer recipient
//         zone.setExpectedOfferRecipient(offerer2.addr);

//         (
//             Order[] memory orders,
//             Fulfillment[] memory fulfillments,
//             ,

//         ) = _buildFulfillmentDataMirrorOrdersNoConduit(context);

//         context.seaport.matchOrders{ value: 2 ether }({
//             orders: orders,
//             fulfillments: fulfillments
//         });
//     }

//     function testMatchAdvancedFullRestrictedOrdersNoConduit() public {
//         test(
//             this.execMatchAdvancedFullRestrictedOrdersNoConduit,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execMatchAdvancedFullRestrictedOrdersNoConduit,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function execMatchAdvancedFullRestrictedOrdersNoConduit(
//         Context memory context
//     ) external stateless {
//         // set offerer2 as the expected offer recipient
//         zone.setExpectedOfferRecipient(offerer2.addr);

//         Fulfillment[] memory fulfillments;
//         AdvancedOrder[] memory advancedOrders;

//         {
//             Order[] memory orders;
//             (
//                 orders,
//                 fulfillments,
//                 ,

//             ) = _buildFulfillmentDataMirrorOrdersNoConduit(context);

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, "")
//             );
//         }

//         CriteriaResolver[] memory criteriaResolvers = new CriteriaResolver[](0);

//         context.seaport.matchAdvancedOrders{ value: 1 ether }(
//             advancedOrders,
//             criteriaResolvers,
//             fulfillments,
//             address(0)
//         );
//     }

//     function testExecMatchAdvancedMirrorContractOrdersWithConduitNoConduit()
//         public
//     {
//         test(
//             this.execMatchAdvancedMirrorContractOrdersWithConduitNoConduit,
//             Context({ seaport: consideration })
//         );
//         // test(
//         //     this.execMatchAdvancedMirrorContractOrdersWithConduitNoConduit,
//         //     Context({ seaport: referenceConsideration })
//         // );
//     }

//     function execMatchAdvancedMirrorContractOrdersWithConduitNoConduit(
//         Context memory context
//     ) external stateless {
//         Fulfillment[] memory fulfillments;
//         AdvancedOrder[] memory advancedOrders;
//         bytes32[2][] memory orderHashes;
//         bytes32[2][] memory calldataHashes;

//         {
//             Order[] memory orders;
//             (
//                 orders,
//                 fulfillments,
//                 ,

//             ) = _buildFulfillmentDataMirrorContractOrdersWithConduitNoConduit(
//                 context
//             );

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, "")
//             );

//             orderHashes = _getOrderHashes(context, orders);
//             calldataHashes = _generateContractOrderDataHashes(
//                 context,
//                 orders
//             );
//         }

//         {
//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 advancedOrders[0].parameters.offerer
//             );
//             emit GenerateOrderDataHash(orderHashes[0][0], calldataHashes[0][0]);

//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 advancedOrders[1].parameters.offerer
//             );
//             emit GenerateOrderDataHash(orderHashes[1][0], calldataHashes[1][0]);

//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 advancedOrders[0].parameters.offerer
//             );
//             emit RatifyOrderDataHash(orderHashes[0][1], calldataHashes[0][1]);

//             vm.expectEmit(
//                 true,
//                 false,
//                 false,
//                 true,
//                 advancedOrders[1].parameters.offerer
//             );
//             emit RatifyOrderDataHash(orderHashes[1][1], calldataHashes[1][1]);
//         }
//         CriteriaResolver[] memory criteriaResolvers = new CriteriaResolver[](0);

//         context.seaport.matchAdvancedOrders(
//             advancedOrders,
//             criteriaResolvers,
//             fulfillments,
//             address(0)
//         );
//     }

//     function testExecMatchAdvancedMirrorOrdersRestrictedAndUnrestricted()
//         public
//     {
//         test(
//             this.execMatchAdvancedMirrorOrdersRestrictedAndUnrestricted,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execMatchAdvancedMirrorOrdersRestrictedAndUnrestricted,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function execMatchAdvancedMirrorOrdersRestrictedAndUnrestricted(
//         Context memory context
//     ) external stateless {
//         // set offerer2 as the expected offer recipient
//         zone.setExpectedOfferRecipient(offerer2.addr);

//         Fulfillment[] memory fulfillments;
//         AdvancedOrder[] memory advancedOrders;

//         {
//             Order[] memory orders;
//             (
//                 orders,
//                 fulfillments,
//                 ,

//             ) = _buildFulfillmentDataMirrorOrdersRestrictedAndUnrestricted(
//                 context
//             );

//             // Convert the orders to advanced orders.
//             advancedOrders = SeaportArrays.AdvancedOrders(
//                 orders[0].toAdvancedOrder(1, 1, ""),
//                 orders[1].toAdvancedOrder(1, 1, "")
//             );
//         }

//         CriteriaResolver[] memory criteriaResolvers = new CriteriaResolver[](0);

//         context.seaport.matchAdvancedOrders{ value: 1 ether }(
//             advancedOrders,
//             criteriaResolvers,
//             fulfillments,
//             address(0)
//         );
//     }

//     function testMatchOrdersToxicOfferItem() public {
//         test(
//             this.execMatchOrdersToxicOfferItem,
//             Context({ seaport: consideration })
//         );
//         test(
//             this.execMatchOrdersToxicOfferItem,
//             Context({ seaport: referenceConsideration })
//         );
//     }

//     function execMatchOrdersToxicOfferItem(
//         Context memory context
//     ) external stateless {
//         // Create token that reverts upon calling transferFrom
//         TestERC721Revert toxicErc721 = new TestERC721Revert();

//         // Mint token to offerer1
//         toxicErc721.mint(offerer1.addr, 1);

//         OfferItem[] memory offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(toxicErc721))
//                 .withIdentifierOrCriteria(1)
//         );
//         ConsiderationItem[] memory considerationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                     offerer1.addr
//                 )
//             );
//         // build first order components
//         OrderComponents memory orderComponents = OrderComponentsLib
//             .fromDefault(VALIDATION_ZONE)
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withCounter(context.seaport.getCounter(offerer1.addr));

//         // second order components only differs by what is offered
//         offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_2))
//                 .withIdentifierOrCriteria(1)
//         );

//         // technically we do not need to copy() since first order components is
//         // not used again, but to encourage good practices, make a copy and
//         // edit that
//         OrderComponents memory orderComponents2 = orderComponents
//             .copy()
//             .withOffer(offerArray);

//         Order[] memory primeOrders = _buildOrders(
//             context,
//             SeaportArrays.OrderComponentsArray(
//                 orderComponents,
//                 orderComponents2
//             ),
//             offerer1.key
//         );

//         // Build the mirror order.
//         OfferItem[] memory mirrorOfferArray = SeaportArrays.OfferItems(
//             OfferItemLib.fromDefault(ONE_ETH),
//             OfferItemLib.fromDefault(ONE_ETH)
//         );
//         ConsiderationItem[] memory mirrorConsiderationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(toxicErc721))
//                     .withIdentifierOrCriteria(1),
//                 ConsiderationItemLib
//                     .fromDefault(SINGLE_721)
//                     .withToken(address(test721_2))
//                     .withIdentifierOrCriteria(1)
//             );
//         // build first order components
//         OrderComponents memory mirrorOrderComponents = OrderComponentsLib
//             .fromDefault(VALIDATION_ZONE)
//             .withOffer(mirrorOfferArray)
//             .withConsideration(mirrorConsiderationArray)
//             .withCounter(context.seaport.getCounter(address(this)));

//         Order[] memory mirrorOrder = _buildOrders(
//             context,
//             SeaportArrays.OrderComponentsArray(mirrorOrderComponents),
//             offerer1.key
//         );

//         Order[] memory orders = new Order[](3);
//         orders[0] = primeOrders[0];
//         orders[1] = primeOrders[1];
//         orders[2] = mirrorOrder[0];

//         (Fulfillment[] memory fulfillments, , ) = matchFulfillmentHelper
//             .getMatchedFulfillments(orders);

//         vm.expectRevert(
//             "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//         );
//         context.seaport.matchOrders{ value: 2 ether }({
//             orders: orders,
//             fulfillments: fulfillments
//         });
//     }

//     ///@dev build multiple orders from the same offerer
//     function _buildOrders(
//         Context memory context,
//         OrderComponents[] memory orderComponents,
//         uint256 key
//     ) internal view returns (Order[] memory) {
//         Order[] memory orders = new Order[](orderComponents.length);
//         for (uint256 i = 0; i < orderComponents.length; i++) {
//             if (orderComponents[i].orderType == OrderType.CONTRACT)
//                 orders[i] = _toUnsignedOrder(orderComponents[i]);
//             else orders[i] = _toOrder(context.seaport, orderComponents[i], key);
//         }
//         return orders;
//     }

//     function _buildFulfillmentData(
//         Context memory context
//     )
//         internal
//         returns (
//             Order[] memory,
//             FulfillmentComponent[][] memory,
//             FulfillmentComponent[][] memory,
//             bytes32,
//             uint256
//         )
//     {
//         ConsiderationItem[] memory considerationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                     offerer1.addr
//                 )
//             );
//         OfferItem[] memory offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//         );
//         // build first order components
//         OrderComponents memory orderComponents = OrderComponentsLib
//             .fromDefault(VALIDATION_ZONE)
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withCounter(context.seaport.getCounter(offerer1.addr));

//         // second order components only differs by what is offered
//         offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_2))
//                 .withIdentifierOrCriteria(1)
//         );
//         // technically there's no need to copy() since first order components is
//         // not used again, but to encourage good practices, make a copy and
//         // edit that
//         OrderComponents memory orderComponents2 = orderComponents
//             .copy()
//             .withOffer(offerArray);

//         Order[] memory orders = _buildOrders(
//             context,
//             SeaportArrays.OrderComponentsArray(
//                 orderComponents,
//                 orderComponents2
//             ),
//             offerer1.key
//         );

//         (
//             FulfillmentComponent[][] memory offerFulfillments,
//             FulfillmentComponent[][] memory considerationFulfillments
//         ) = fulfill.getAggregatedFulfillmentComponents(orders);

//         return (
//             orders,
//             offerFulfillments,
//             considerationFulfillments,
//             conduitKeyOne,
//             2
//         );
//     }

//     //@dev builds fulfillment data for a contract order from the
//     //     TestTransferValidationZoneOfferer and its mirror order
//     //     (one offerItem and one considerationItem)
//     function _buildFulfillmentDataMirrorContractOrders(
//         Context memory context
//     )
//         internal
//         returns (Order[] memory, Fulfillment[] memory, bytes32, bytes32)
//     {
//         // Create contract offerers
//         TestCalldataHashContractOfferer transferValidationOfferer1 = new TestCalldataHashContractOfferer(
//                 address(context.seaport)
//             );
//         TestCalldataHashContractOfferer transferValidationOfferer2 = new TestCalldataHashContractOfferer(
//                 address(context.seaport)
//             );

//         transferValidationOfferer1.setExpectedOfferRecipient(
//             address(transferValidationOfferer2)
//         );
//         transferValidationOfferer2.setExpectedOfferRecipient(
//             address(transferValidationOfferer1)
//         );

//         vm.label(address(transferValidationOfferer1), "contractOfferer1");
//         vm.label(address(transferValidationOfferer2), "contractOfferer2");

//         _setApprovals(address(transferValidationOfferer1));
//         _setApprovals(address(transferValidationOfferer2));

//         // Mint 721 to offerer1
//         test721_1.mint(offerer1.addr, 1);

//         // offerer1 approves transferValidationOfferer1
//         vm.prank(offerer1.addr);
//         test721_1.setApprovalForAll(address(transferValidationOfferer1), true);

//         // Create one eth consideration for contract order 1
//         ConsiderationItem[] memory considerationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                     address(transferValidationOfferer1)
//                 )
//             );
//         // Create single 721 offer for contract order 1
//         OfferItem[] memory offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//         );
//         // Build first order components
//         OrderComponents memory orderComponents = OrderComponentsLib
//             .fromDefault(CONTRACT_ORDER)
//             .withOfferer(address(transferValidationOfferer1))
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withCounter(
//                 context.seaport.getCounter(address(transferValidationOfferer1))
//             );

//         // Second order components mirror first order components
//         // Create one eth offer for contract order 2
//         offerArray = SeaportArrays.OfferItems(
//             OfferItemLib.fromDefault(ONE_ETH)
//         );

//         // Create one 721 consideration for contract order 2
//         considerationArray = SeaportArrays.ConsiderationItems(
//             ConsiderationItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//                 .withRecipient(address(transferValidationOfferer2))
//         );
//         // technically there's no need to copy() since first order components is
//         // not used again, but to encourage good practices, make a copy and
//         // edit that
//         OrderComponents memory orderComponents2 = orderComponents
//             .copy()
//             .withOfferer(address(transferValidationOfferer2))
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withCounter(
//                 context.seaport.getCounter(address(transferValidationOfferer2))
//             );

//         Order[] memory orders = _buildOrders(
//             context,
//             SeaportArrays.OrderComponentsArray(
//                 orderComponents,
//                 orderComponents2
//             ),
//             offerer1.key
//         );

//         (Fulfillment[] memory fulfillments, , ) = matchFulfillmentHelper
//             .getMatchedFulfillments(orders);

//         // Convert OfferItem[] and ConsiderationItem[] to SpentItem[] to call activate
//         // 1 eth
//         SpentItem[] memory minimumReceived = offerArray.toSpentItemArray();
//         // single 721
//         SpentItem[] memory maximumSpent = considerationArray.toSpentItemArray();

//         vm.deal(offerer2.addr, 1 ether);

//         // Activate the orders
//         // offerer1 receives 1 eth in exchange for 721
//         vm.prank(offerer1.addr);
//         transferValidationOfferer1.activate(
//             address(this),
//             maximumSpent,
//             minimumReceived,
//             ""
//         );
//         vm.prank(offerer2.addr);
//         // offerer2 receives 721 in exchange for 1 eth
//         transferValidationOfferer2.activate{ value: 1 ether }(
//             address(this),
//             minimumReceived,
//             maximumSpent,
//             ""
//         );

//         bytes32 firstOrderDataHash = keccak256(
//             abi.encodeCall(
//                 ContractOffererInterface.generateOrder,
//                 (address(this), maximumSpent, minimumReceived, "")
//             )
//         );

//         bytes32 secondOrderDataHash = keccak256(
//             abi.encodeCall(
//                 ContractOffererInterface.generateOrder,
//                 (address(this), minimumReceived, maximumSpent, "")
//             )
//         );

//         return (orders, fulfillments, firstOrderDataHash, secondOrderDataHash);
//     }

//     function _buildFulfillmentDataMirrorContractOrdersWithConduitNoConduit(
//         Context memory context
//     )
//         internal
//         returns (Order[] memory, Fulfillment[] memory, bytes32, bytes32)
//     {
//         // Create contract offerers
//         TestCalldataHashContractOfferer transferValidationOfferer1 = new TestCalldataHashContractOfferer(
//                 address(context.seaport)
//             );
//         TestCalldataHashContractOfferer transferValidationOfferer2 = new TestCalldataHashContractOfferer(
//                 address(context.seaport)
//             );

//         transferValidationOfferer1.setExpectedOfferRecipient(
//             address(transferValidationOfferer2)
//         );
//         transferValidationOfferer2.setExpectedOfferRecipient(
//             address(transferValidationOfferer1)
//         );

//         vm.label(address(transferValidationOfferer1), "contractOfferer1");
//         vm.label(address(transferValidationOfferer2), "contractOfferer2");

//         _setApprovals(address(transferValidationOfferer1));
//         _setApprovals(address(transferValidationOfferer2));

//         // Mint 721 to offerer1
//         test721_1.mint(offerer1.addr, 1);

//         // offerer1 approves transferValidationOfferer1
//         vm.prank(offerer1.addr);
//         test721_1.setApprovalForAll(address(transferValidationOfferer1), true);

//         // Create single 721 offer for contract order 1
//         OfferItem[] memory offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//         );
//         // Create one eth consideration for contract order 1
//         ConsiderationItem[] memory considerationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                     address(transferValidationOfferer1)
//                 )
//             );

//         // Build first order components
//         OrderComponents memory orderComponents = OrderComponentsLib
//             .fromDefault(CONTRACT_ORDER)
//             .withOfferer(address(transferValidationOfferer1))
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withCounter(
//                 context.seaport.getCounter(address(transferValidationOfferer1))
//             );

//         // Second order components mirror first order components
//         // Create one eth offer for contract order 2
//         offerArray = SeaportArrays.OfferItems(
//             OfferItemLib.fromDefault(ONE_ETH)
//         );

//         // Create one 721 consideration for contract order 2
//         considerationArray = SeaportArrays.ConsiderationItems(
//             ConsiderationItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//                 .withRecipient(address(transferValidationOfferer2))
//         );

//         // copy first order components and set conduit key to 0
//         OrderComponents memory orderComponents2 = orderComponents
//             .copy()
//             .withOfferer(address(transferValidationOfferer2))
//             .withConduitKey(bytes32(0))
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withCounter(
//                 context.seaport.getCounter(address(transferValidationOfferer2))
//             );

//         Order[] memory orders = _buildOrders(
//             context,
//             SeaportArrays.OrderComponentsArray(
//                 orderComponents,
//                 orderComponents2
//             ),
//             offerer1.key
//         );

//         (Fulfillment[] memory fulfillments, , ) = matchFulfillmentHelper
//             .getMatchedFulfillments(orders);

//         // Convert OfferItem[] and ConsiderationItem[] to SpentItem[] to call activate
//         // 1 eth
//         SpentItem[] memory minimumReceived = offerArray.toSpentItemArray();
//         // single 721
//         SpentItem[] memory maximumSpent = considerationArray.toSpentItemArray();

//         vm.deal(offerer2.addr, 1 ether);

//         // Activate the orders
//         // offerer1 receives 1 eth in exchange for 721
//         vm.prank(offerer1.addr);
//         transferValidationOfferer1.activate(
//             address(this),
//             maximumSpent,
//             minimumReceived,
//             ""
//         );
//         vm.prank(offerer2.addr);
//         // offerer2 receives 721 in exchange for 1 eth
//         transferValidationOfferer2.activate{ value: 1 ether }(
//             address(this),
//             minimumReceived,
//             maximumSpent,
//             ""
//         );

//         bytes32 firstOrderDataHash = keccak256(
//             abi.encodeCall(
//                 ContractOffererInterface.generateOrder,
//                 (address(this), maximumSpent, minimumReceived, "")
//             )
//         );

//         bytes32 secondOrderDataHash = keccak256(
//             abi.encodeCall(
//                 ContractOffererInterface.generateOrder,
//                 (address(this), minimumReceived, maximumSpent, "")
//             )
//         );

//         return (orders, fulfillments, firstOrderDataHash, secondOrderDataHash);
//     }

//     /// @dev Generates calldata hashes for calls to generateOrder and
//     ///      ratifyOrder from mirror orders. Assumes the following:
//     ///         1. Context is empty for all orders.
//     ///         2. All passed in orders can be matched with each other.
//     ///              a. All orderHashes will be passed into call to ratifyOrder
//     function _generateContractOrderDataHashes(
//         Context memory context,
//         Order[] memory orders
//     ) internal returns (bytes32[2][] memory) {
//         uint256 orderCount = orders.length;
//         bytes32[2][] memory orderHashes = _getOrderHashes(context, orders);

//         bytes32[2][] memory calldataHashes = new bytes32[2][](orderCount);

//         // Iterate over orders to generate dataHashes
//         for (uint256 i = 0; i < orderCount; i++) {
//             Order memory order = orders[i];

//             if (order.parameters.orderType != OrderType.CONTRACT) {
//                 continue;
//             }

//             // Convert OfferItem[] and ConsiderationItem[] to SpentItem[]
//             SpentItem[] memory minimumReceived = order
//                 .parameters
//                 .offer
//                 .toSpentItemArray();
//             SpentItem[] memory maximumSpent = order
//                 .parameters
//                 .consideration
//                 .toSpentItemArray();

//             // hash of generateOrder calldata
//             calldataHashes[i][0] = keccak256(
//                 abi.encodeCall(
//                     ContractOffererInterface.generateOrder,
//                     (address(this), minimumReceived, maximumSpent, "")
//                 )
//             );

//             ReceivedItem[] memory receivedItems = order
//                 .parameters
//                 .consideration
//                 .toReceivedItemArray();

//             bytes32[] memory unmaskedHashes = new bytes32[](orderCount);
//             for (uint256 j = 0; j < orderCount; j++) {
//                 unmaskedHashes[j] = orderHashes[j][0];
//             }
//             // hash of ratifyOrder calldata
//             calldataHashes[i][1] = keccak256(
//                 abi.encodeCall(
//                     ContractOffererInterface.ratifyOrder,
//                     (
//                         minimumReceived,
//                         receivedItems,
//                         "",
//                         unmaskedHashes,
//                         context.seaport.getCounter(order.parameters.offerer)
//                     )
//                 )
//             );
//         }

//         return calldataHashes;
//     }

//     function _getOrderHashes(
//         Context memory context,
//         Order[] memory orders
//     ) internal returns (bytes32[2][] memory) {
//         bytes32[2][] memory orderHashes = new bytes32[2][](orders.length);

//         // Iterate over all orders to derive orderHashes
//         for (uint256 i; i < orders.length; ++i) {
//             Order memory order = orders[i];

//             if (order.parameters.orderType == OrderType.CONTRACT) {
//                 // Get contract nonce of the offerer
//                 uint256 contractNonce = context.seaport.getContractOffererNonce(
//                     order.parameters.offerer
//                 );

//                 bytes32 orderHash = bytes32(
//                     contractNonce ^
//                         (uint256(uint160(order.parameters.offerer)) << 96)
//                 );

//                 // Get the contract order's orderHash
//                 orderHashes[i][0] = orderHash;

//                 // Mask the original orderHash
//                 bytes32 maskedHash;
//                 bytes32 mask = bytes32(
//                     0x0000000000000000000000000000000000000000000000000000000000000001
//                 );

//                 assembly {
//                     maskedHash := or(orderHash, mask)
//                 }

//                 orderHashes[i][1] = maskedHash;
//             } else {
//                 // Get OrderComponents from OrderParameters
//                 OrderComponents memory orderComponents = order
//                     .parameters
//                     .toOrderComponents(
//                         context.seaport.getCounter(order.parameters.offerer)
//                     );

//                 // Derive the orderHash from OrderComponents
//                 orderHashes[i][0] = context.seaport.getOrderHash(
//                     orderComponents
//                 );
//                 orderHashes[i][1] = context.seaport.getOrderHash(
//                     orderComponents
//                 );
//             }
//         }

//         return orderHashes;
//     }

//     function _emitZoneValidateOrderDataHashes(
//         ZoneParameters[] memory zoneParameters
//     ) internal {
//         // Create bytes32[] to hold the hashes.
//         bytes32[] memory payloadHashes = new bytes32[](zoneParameters.length);

//         // Iterate over each ZoneParameters to generate the hash.
//         for (uint256 i = 0; i < zoneParameters.length; i++) {
//             // Generate the hash.
//             payloadHashes[i] = keccak256(
//                 abi.encodeCall(ZoneInterface.validateOrder, (zoneParameters[i]))
//             );

//             // Expect the hash to be emitted in the call to Seaport
//             vm.expectEmit(false, false, false, true);

//             // Emit the expected event with the expected hash.
//             emit ValidateOrderDataHash(payloadHashes[i]);
//         }
//     }

//     function _buildFulfillmentDataOpenOrderAndMirrorContractOrder(
//         Context memory context
//     )
//         internal
//         returns (Order[] memory, Fulfillment[] memory, bytes32, uint256)
//     {
//         // Create contract offerer
//         TestCalldataHashContractOfferer transferValidationOfferer1 = new TestCalldataHashContractOfferer(
//                 address(context.seaport)
//             );

//         vm.label(address(transferValidationOfferer1), "contractOfferer");

//         transferValidationOfferer1.setExpectedOfferRecipient(
//             address(offerer2.addr)
//         );

//         TestTransferValidationZoneOfferer transferValidationZone = new TestTransferValidationZoneOfferer(
//                 address(transferValidationOfferer1)
//             );

//         _setApprovals(address(transferValidationOfferer1));

//         // Mint 721 to offerer 1
//         test721_1.mint(offerer1.addr, 1);

//         // offerer1 approves transferValidationOfferer1
//         vm.prank(offerer1.addr);
//         test721_1.setApprovalForAll(address(transferValidationOfferer1), true);

//         // Create single 721 offer for contract order 1
//         OfferItem[] memory offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//         );
//         // Create one eth consideration for contract order 1
//         ConsiderationItem[] memory considerationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                     address(transferValidationOfferer1)
//                 )
//             );

//         // Build first order components
//         OrderComponents memory orderComponents = OrderComponentsLib
//             .fromDefault(CONTRACT_ORDER)
//             .withOfferer(address(transferValidationOfferer1))
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withCounter(
//                 context.seaport.getCounter(address(transferValidationOfferer1))
//             );

//         // Second order components mirror first order components
//         // Create one eth offer for open order
//         offerArray = SeaportArrays.OfferItems(
//             OfferItemLib.fromDefault(ONE_ETH)
//         );

//         // Create one 721 consideration for open order
//         considerationArray = SeaportArrays.ConsiderationItems(
//             ConsiderationItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//                 .withRecipient(offerer2.addr)
//         );

//         OrderComponents memory orderComponents2 = OrderComponentsLib
//             .fromDefault(VALIDATION_ZONE)
//             .withOfferer(offerer2.addr)
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withZone(address(transferValidationZone))
//             .withCounter(context.seaport.getCounter(offerer2.addr));

//         Order[] memory orders = _buildOrders(
//             context,
//             SeaportArrays.OrderComponentsArray(
//                 orderComponents,
//                 orderComponents2
//             ),
//             offerer2.key
//         );

//         (Fulfillment[] memory fulfillments, , ) = matchFulfillmentHelper
//             .getMatchedFulfillments(orders);

//         // Convert OfferItem[] and ConsiderationItem[] to SpentItem[] to call activate
//         // 1 eth
//         SpentItem[] memory minimumReceived = offerArray.toSpentItemArray();
//         // single 721
//         SpentItem[] memory maximumSpent = considerationArray.toSpentItemArray();

//         // Activate the orders
//         // offerer1 receives 1 eth in exchange for 721
//         vm.prank(offerer1.addr);
//         transferValidationOfferer1.activate(
//             address(this),
//             maximumSpent,
//             minimumReceived,
//             ""
//         );

//         return (orders, fulfillments, conduitKeyOne, 2);
//     }

//     function _buildFulfillmentDataMirrorOrdersRestrictedAndUnrestricted(
//         Context memory context
//     )
//         internal
//         returns (Order[] memory, Fulfillment[] memory, bytes32, uint256)
//     {
//         // mint 721 to offerer 1
//         test721_1.mint(offerer1.addr, 1);

//         OfferItem[] memory offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//         );
//         ConsiderationItem[] memory considerationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                     offerer1.addr
//                 )
//             );

//         // build first restricted order components, remove conduit key
//         OrderComponents memory orderComponents = OrderComponentsLib
//             .fromDefault(VALIDATION_ZONE)
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withConduitKey(bytes32(0))
//             .withCounter(context.seaport.getCounter(offerer1.addr));

//         // create mirror offer and consideration
//         offerArray = SeaportArrays.OfferItems(
//             OfferItemLib.fromDefault(ONE_ETH)
//         );

//         considerationArray = SeaportArrays.ConsiderationItems(
//             ConsiderationItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//                 .withRecipient(offerer2.addr)
//         );

//         // build second unrestricted order components, remove zone
//         OrderComponents memory orderComponents2 = orderComponents
//             .copy()
//             .withOrderType(OrderType.FULL_OPEN)
//             .withOfferer(offerer2.addr)
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withZone(address(0))
//             .withCounter(context.seaport.getCounter(offerer2.addr));

//         Order[] memory orders = new Order[](2);

//         orders[0] = _toOrder(context.seaport, orderComponents, offerer1.key);
//         orders[1] = _toOrder(context.seaport, orderComponents2, offerer2.key);

//         (Fulfillment[] memory fulfillments, , ) = matchFulfillmentHelper
//             .getMatchedFulfillments(orders);

//         return (orders, fulfillments, bytes32(0), 2);
//     }

//     function _buildFulfillmentDataMirrorOrdersNoConduit(
//         Context memory context
//     )
//         internal
//         returns (Order[] memory, Fulfillment[] memory, bytes32, uint256)
//     {
//         // mint 721 to offerer 1
//         test721_1.mint(offerer1.addr, 1);

//         OfferItem[] memory offerArray = SeaportArrays.OfferItems(
//             OfferItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//         );
//         ConsiderationItem[] memory considerationArray = SeaportArrays
//             .ConsiderationItems(
//                 ConsiderationItemLib.fromDefault(ONE_ETH).withRecipient(
//                     offerer1.addr
//                 )
//             );

//         // build first order components, remove conduit key
//         OrderComponents memory orderComponents = OrderComponentsLib
//             .fromDefault(VALIDATION_ZONE)
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withConduitKey(bytes32(0))
//             .withCounter(context.seaport.getCounter(offerer1.addr));

//         // create mirror offer and consideration
//         offerArray = SeaportArrays.OfferItems(
//             OfferItemLib.fromDefault(ONE_ETH)
//         );

//         considerationArray = SeaportArrays.ConsiderationItems(
//             ConsiderationItemLib
//                 .fromDefault(SINGLE_721)
//                 .withToken(address(test721_1))
//                 .withIdentifierOrCriteria(1)
//                 .withRecipient(offerer2.addr)
//         );

//         OrderComponents memory orderComponents2 = OrderComponentsLib
//             .fromDefault(VALIDATION_ZONE)
//             .withOfferer(offerer2.addr)
//             .withOffer(offerArray)
//             .withConsideration(considerationArray)
//             .withConduitKey(bytes32(0))
//             .withCounter(context.seaport.getCounter(offerer2.addr));

//         Order[] memory orders = new Order[](2);

//         orders[0] = _toOrder(context.seaport, orderComponents, offerer1.key);
//         orders[1] = _toOrder(context.seaport, orderComponents2, offerer2.key);

//         (Fulfillment[] memory fulfillments, , ) = matchFulfillmentHelper
//             .getMatchedFulfillments(orders);

//         return (orders, fulfillments, bytes32(0), 2);
//     }

//     function _toOrder(
//         ConsiderationInterface seaport,
//         OrderComponents memory orderComponents,
//         uint256 pkey
//     ) internal view returns (Order memory order) {
//         bytes32 orderHash = seaport.getOrderHash(orderComponents);
//         bytes memory signature = signOrder(seaport, pkey, orderHash);
//         order = OrderLib
//             .empty()
//             .withParameters(orderComponents.toOrderParameters())
//             .withSignature(signature);
//     }

//     function _toUnsignedOrder(
//         OrderComponents memory orderComponents
//     ) internal pure returns (Order memory order) {
//         order = OrderLib.empty().withParameters(
//             orderComponents.toOrderParameters()
//         );
//     }
// }
