module Payoneer
  module Payout
    extend Payoneer::RemoteApi

    def create(payment_id:, payee_id:, amount:, description:, currency: 'USD')
      submit_payout(
        {
          payments: [
            {
              client_reference_id: payment_id,
              payee_id: payee_id,
              amount: amount,
              description: description,
              currency: currency
            }
          ]
        }
      )
      payout_status(payment_id)
    rescue Payoneer::Error => e
      Status.new({
        result: {
          status: 'Failed',
          error: {
            description: e.description,
            reason: e.details
          }
        }
      }, payment_id)
    end

    def status(client_reference_id)
      payout_status(client_reference_id)
    end

    private

    def submit_payout(params)
      post(
        path: "/programs/#{Payoneer::Configuration.program_id}/masspayouts",
        body: params
      )
    end

    def payout_status(client_reference_id)
      response = get(
        path: "/programs/#{Payoneer::Configuration.program_id}/payouts"\
              "/#{client_reference_id}/status"
      )
      Status.new(response, client_reference_id)
    end
  end
end
