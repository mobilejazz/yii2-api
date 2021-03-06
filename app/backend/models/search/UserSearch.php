<?php

namespace backend\models\search;

use common\models\User;
use Yii;
use yii\base\Model;
use yii\data\ActiveDataProvider;

/**
 * UserSearch represents the model behind the search form about `common\models\User`.
 */
class UserSearch extends User
{
    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [ [ 'id', 'role', 'status' ], 'integer' ],
            [ [ 'email', 'auth_key', 'password_hash', 'password_reset_token', 'name', 'last_name', 'created_at', 'updated_at' ], 'safe' ],
        ];
    }

    /**
     * @inheritdoc
     */
    public function scenarios()
    {
        // bypass scenarios() implementation in the parent class
        return Model::scenarios();
    }

    /**
     * Creates data provider instance with search query applied
     *
     * @param array $params
     *
     * @return ActiveDataProvider
     */
    public function search($params)
    {
        $query = User::find();

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
        ]);

        $this->load($params);

        if ( ! $this->validate())
        {
            // uncomment the following line if you do not want to return any records when validation fails
            // $query->where('0=1');
            return $dataProvider;
        }

        $query->andFilterWhere([
            'id'         => $this->id,
            'role'       => $this->role,
            'status'     => $this->status,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ]);

        $query->andFilterWhere([ 'like', 'email', $this->email ])
            ->andFilterWhere([ 'like', 'auth_key', $this->auth_key ])
            ->andFilterWhere([ 'like', 'password_hash', $this->password_hash ])
            ->andFilterWhere([ 'like', 'password_reset_token', $this->password_reset_token ])
            ->andFilterWhere([ 'like', 'name', $this->name ])
            ->andFilterWhere([ 'like', 'last_name', $this->last_name ]);

        return $dataProvider;
    }
}
