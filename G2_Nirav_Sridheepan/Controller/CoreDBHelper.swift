//
//  CoreDBHelper.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import Foundation
import CoreData
import UIKit

class CoreDBHelper{
    private static var shared : CoreDBHelper?
    private let moc : NSManagedObjectContext
    private let ENTITY_USER = "Users"
    private let ENTITY_Order = "Orders"
    
    private var loggedInUser: Users? = nil
    
    func addLoggedInUser(loggedInUser: Users){
        self.loggedInUser = loggedInUser
    }
    
    func getLoggedInUser() -> Users?{
        return self.loggedInUser
    }
    
    static func getInstance() -> CoreDBHelper{
        
        if(shared == nil){
            shared = CoreDBHelper(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        }
        
        return shared!
    }
    
    private init(context: NSManagedObjectContext){
        self.moc = context
    }
    
    //MARK: CRUD functions for Users
    
    //Insert users into database
    func insertUser(email:String, password: String, fullname: String, userImage: Data){
        do{
            let userDetails = NSEntityDescription.insertNewObject(forEntityName: ENTITY_USER, into: self.moc) as! Users

            userDetails.email_id = email.lowercased()
            userDetails.password = password
            userDetails.full_name = fullname.upperCamelCased
            userDetails.userImage = userImage
            userDetails.date_created = Date()
            userDetails.id = UUID()

            if self.moc.hasChanges{
                try self.moc.save()

                print(#function, "Data successfully saved")
            }
        }
        catch let error as NSError {
            print(#function, "Could not save the data \(error)")
        }
    }
    
    //select all user data from database
    func getAllUsers() -> [Users]?{
        let fetchData = NSFetchRequest<Users>(entityName: ENTITY_USER)
        fetchData.sortDescriptors = [NSSortDescriptor.init(key: "date_created", ascending: false)]
        
        do{
            let result = try self.moc.fetch(fetchData)
            print(#function, "Fetched data: \(result as [Users])")
            return result as [Users]
        }catch let error as NSError {
            print(#function, "Could not fetch the user details from database \(error)")
        }
        
        return nil
    }
    
    //Search and check if email address is exists in database
    func isEmailAddressExist(emailAddress : String) -> Bool{
        let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_USER)
        let data = NSPredicate(format: "email_id == %@", emailAddress as CVarArg)
        fetchData.predicate = data
        
        do{
            let result = try self.moc.fetch(fetchData)
            if(result.count > 0){
                print(#function, "Matching record found")
                return true
                //return result.first as? Orders
            }
        }catch let error as NSError {
            print(#function, "Could not search for order \(error)")
        }
        
        return false
    }
    
    //search for user
    func searchUser(emailAddress : String, password: String) -> Users?{
        let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_USER)
        //let data = NSPredicate(format: "email_id == %@", emailAddress as CVarArg)
        let checkEmail = NSPredicate(format: "email_id == %@", emailAddress.lowercased() as CVarArg)
        let checkPassword = NSPredicate(format: "password == %@", password as CVarArg)
        let data = NSCompoundPredicate(type: .and, subpredicates: [checkEmail,checkPassword])
        fetchData.predicate = data
        
        do{
            let result = try self.moc.fetch(fetchData)
            if(result.count > 0){
                print(#function, "Matching record found")
                return result.first as? Users
            }
        }catch let error as NSError {
            print(#function, "Could not find the user \(error)")
        }
        
        return nil
    }
    
    func searchUserWithID(id : UUID) -> Users?{
        let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_USER)
        let data = NSPredicate(format: "id == %@", id as CVarArg)
        fetchData.predicate = data
        
        do{
            let result = try self.moc.fetch(fetchData)
            if(result.count > 0){
                print(#function, "Matching record found")
                return result.first as? Users
            }
        }catch let error as NSError {
            print(#function, "Could not find the user \(error)")
        }
        
        return nil
    }
    
    
    
    // MARK: CRUD functions for orders
    //Insert users into database
    func insertOrder(user_id:UUID, tasker_id: String, task_date: String, is_promocode_used: Bool, promocode: String, promocode_per_val: Int, order_amount: Double){
        do{
            let OrderDetails = NSEntityDescription.insertNewObject(forEntityName: ENTITY_Order, into: self.moc) as! Orders
            var promoToAdd = promocode
            var promoValToAdd = promocode_per_val
            
            if(!is_promocode_used){
                promoToAdd = ""
                promoValToAdd = 0
            }
            
            OrderDetails.user_id = user_id
            OrderDetails.tasker_id = tasker_id
            OrderDetails.task_date = task_date
            OrderDetails.is_promocode_used = is_promocode_used
            OrderDetails.promocode = promoToAdd
            OrderDetails.promocode_per_val = Int16(promoValToAdd)
            OrderDetails.order_amount = order_amount
            OrderDetails.order_date = Date()
            OrderDetails.order_id = UUID()

            if self.moc.hasChanges{
                try self.moc.save()

                print(#function, "Data successfully saved")
            }
        }
        catch let error as NSError {
            print(#function, "Could not save the data \(error)")
        }
    }
    
    //select all orders of user from database
    func getAllOrdersForUser(user_id: UUID) -> [Orders]?{
        let fetchData = NSFetchRequest<Orders>(entityName: ENTITY_Order)
        let data = NSPredicate(format: "user_id == %@", user_id as CVarArg)
        fetchData.sortDescriptors = [NSSortDescriptor.init(key: "order_date", ascending: false)]
        fetchData.predicate = data
        
        do{
            let result = try self.moc.fetch(fetchData)
            print(#function, "Fetched data: \(result as [Orders])")
            return result as [Orders]
        }catch let error as NSError {
            print(#function, "Could not fetch the orders from database \(error)")
        }
        
        return nil
    }
    
    //Search for orders
    func searchOrder(order_id : UUID) -> Orders?{
        let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_Order)
        let dataID = NSPredicate(format: "order_id == %@", order_id as CVarArg)
        fetchData.predicate = dataID
        
        do{
            let result = try self.moc.fetch(fetchData)
            if(result.count > 0){
                print(#function, "Matching record found")
                return result.first as? Orders
            }
        }catch let error as NSError {
            print(#function, "Could not search for order \(error)")
        }
        
        return nil
    }
    
    //update order details in database
    func updateOrder(order_id : UUID?, task_date: String){
        let fetchData = self.searchOrder(order_id: order_id! as UUID)
        
        if(fetchData != nil){
            do{
                let order = fetchData!
                
                order.task_date = task_date
                
                try self.moc.save()
                
                print(#function, "Order successfully updated")
                
            } catch let error as NSError{
                print(#function, "Unable to update the order \(error)")
            }
        }
        else{
            print(#function, "No matching order found")
        }
    }
}

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    var upperCamelCased: String {
        return self.lowercased()
            .split(separator: " ")
            .map { return $0.lowercased().capitalizingFirstLetter() }
            .joined(separator: " ")
    }
    
    var lowerCamelCased: String {
        let upperCased = self.upperCamelCased
        return upperCased.prefix(1).lowercased() + upperCased.dropFirst()
    }
}
