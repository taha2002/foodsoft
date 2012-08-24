# This plain ruby class should handle all user notifications, called by various models
class UserNotifier

  def self.finished_order(order_id)
    Order.find(order_id).group_orders.each do |group_order|
      group_order.ordergroup.users.each do |user|
        begin
          Mailer.order_result(user, group_order).deliver if user.settings["notify.orderFinished"] == '1'
        rescue
          Rails.logger.warn "Can't deliver mail to #{user.email}"
        end
      end
    end
  end

  # If this order group's account balance is made negative by the given/last transaction,
  # a message is sent to all users who have enabled notification.
  def self.negative_balance(ordergroup_id, transaction_id)
    transaction = FinancialTransaction.find transaction_id

    Ordergroup.find(ordergroup_id).users.each do |user|
      begin
        Mailer.negative_balance(user, transaction).deliver if user.settings["notify.negativeBalance"] == '1'
      rescue
        Rails.logger.warn "Can't deliver mail to #{user.email}"
      end
    end
  end
end