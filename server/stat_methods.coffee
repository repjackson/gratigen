Meteor.methods
    calc_user_stats: (user_id)->
        user = Meteor.users.findOne user_id
        gift_count =
            Docs.find(
                model:'gift'
                _author_id: user_id
            ).count()

        credit_count =
            Docs.find(
                model:'gift'
                target_id: user_id
            ).count()

        Meteor.users.update user_id,
            $set:
                gift_count:gift_count
                credit_count:credit_count


        gift_count_ranking =
            Meteor.users.find(
                {},
                sort:
                    gift_count: -1
                fields:
                    username: 1
            ).fetch()
        gift_count_ranking_ids = _.pluck gift_count_ranking, '_id'

        console.log 'gift_count_ranking', gift_count_ranking
        console.log 'gift_count_ranking ids', gift_count_ranking_ids
        my_rank = _.indexOf(gift_count_ranking_ids, user_id)+1
        console.log 'my rank', my_rank
        Meteor.users.update user_id,
            $set:
                global_gift_count_rank:my_rank


        credit_count_ranking =
            Meteor.users.find(
                {},
                sort:
                    credit_count: -1
                fields:
                    username: 1
            ).fetch()
        credit_count_ranking_ids = _.pluck credit_count_ranking, '_id'

        console.log 'credit_count_ranking', credit_count_ranking
        console.log 'credit_count_ranking ids', credit_count_ranking_ids
        my_rank = _.indexOf(credit_count_ranking_ids, user_id)+1
        console.log 'my rank', my_rank
        Meteor.users.update user_id,
            $set:
                global_credit_count_rank:my_rank


    calc_user_points: (user_id)->
        user = Meteor.users.findOne user_id
        debits = Docs.find({
            model:'debit'
            amount:$exists:true
            _author_id:user_id})
        debit_count = debits.count()
        total_debit_amount = 0
        for debit in debits.fetch()
            total_debit_amount += debit.amount

        console.log 'total debit amount', total_debit_amount

        credits = Docs.find({
            model:'debit'
            amount:$exists:true
            recipient_id:user_id})
        credit_count = credits.count()
        total_credit_amount = 0
        for credit in credits.fetch()
            total_credit_amount += credit.amount

        console.log 'total credit amount', total_credit_amount
        calculated_user_balance = total_credit_amount-total_debit_amount

        Meteor.users.update user_id,
            $set:
                points:calculated_user_balance
                total_credit_amount: total_credit_amount
                total_debit_amount: total_debit_amount







    calc_global_stats: ()->
        gs = Docs.findOne model:'global_stats'
        unless gs 
            Docs.insert 
                model:'global_stats'
        gs = Docs.findOne model:'global_stats'
        
        total_points = 0
        
        point_users = 
            Meteor.users.find 
                points: $exists:true
        for point_user in point_users.fetch()
            total_points += point_user.points
    
        console.log 'total points', total_points
        Docs.update gs._id,
            $set:total_points:total_points