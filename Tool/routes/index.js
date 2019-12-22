var express = require('express');
var router = express.Router();
var axios = require('axios')

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('home', { title:'Monitoring Tool' });
});

router.get('/tablespaces', function(req, res, next) {
  axios.get('http://localhost:8080/ords/dbmonitoring/tablespaces/ts')
			.then(resposta => {
				res.render('tablespaces', {title:'Tablespaces', lista: resposta.data.items});
			})
			.catch(erro => {
				console.log('Erro ao ler JSON da API REST.')
        		res.render('error', {error: erro})
			})
})

router.get('/tablespaceshist', function(req, res, next) {
	axios.get('http://localhost:8080/ords/dbmonitoring/tablespaceshist/tsh')
			  .then(resposta => {
				  res.render('tablespaceshist', {title:'TS History', lista: resposta.data.items});
			  })
			  .catch(erro => {
				  console.log('Erro ao ler JSON da API REST.')
				  res.render('error', {error: erro})
			  })
  })

router.get('/datafiles', function(req, res, next) {
  axios.get('http://localhost:8080/ords/dbmonitoring/datafiles/dfs')
			.then(resposta => {
				res.render('datafiles', {title:'Datafiles', lista: resposta.data.items});
			})
			.catch(erro => {
				console.log('Erro ao ler JSON da API REST.')
        		res.render('error', {error: erro})
			})
})

router.get('/users', function(req, res, next) {
  axios.get('http://localhost:8080/ords/dbmonitoring/users/usr')
			.then(resposta => {
				res.render('users', {title:'Users', lista: resposta.data.items});
			})
			.catch(erro => {
				console.log('Erro ao ler JSON da API REST.')
        		res.render('error', {error: erro})
			})
})

router.get('/sessions', function(req, res, next) {
  axios.get('http://localhost:8080/ords/dbmonitoring/sessions/sess')
			.then(resposta => {
				res.render('sessions', {title:'Sessions', lista: resposta.data.items});
			})
			.catch(erro => {
				console.log('Erro ao ler JSON da API REST.')
        		res.render('error', {error: erro})
			})
})

router.get('/resources', function(req, res, next) {
	axios.get('http://localhost:8080/ords/dbmonitoring/resources/src')
			  .then(resposta => {
				  res.render('resources', {title:'Resources', lista: resposta.data.items});
			  })
			  .catch(erro => {
				  console.log('Erro ao ler JSON da API REST.')
				  res.render('error', {error: erro})
			  })
})

router.get('/quotas', function(req, res, next) {
	axios.get('http://localhost:8080/ords/dbmonitoring/quotas/qts')
			  .then(resposta => {
				  res.render('quotas', {title:'Quotas', lista: resposta.data.items});
			  })
			  .catch(erro => {
				  console.log('Erro ao ler JSON da API REST.')
				  res.render('error', {error: erro})
			  })
})

router.get('/quotashist', function(req, res, next) {
	axios.get('http://localhost:8080/ords/dbmonitoring/quotashist/qth')
			  .then(resposta => {
				  res.render('quotashist', {title:'Quotas History', lista: resposta.data.items});
			  })
			  .catch(erro => {
				  console.log('Erro ao ler JSON da API REST.')
				  res.render('error', {error: erro})
			  })
})

router.get('/resources/sga', function(req, res, next) {
	axios.get('http://localhost:8080/ords/dbmonitoring/resources/src')
		.then(resposta => {
			lista = []
			for(i = 0; i < resposta.data.items.length; i++)
				if(resposta.data.items[i].origin == "SGA") lista.push('[\''+resposta.data.items[i].name+'\','+resposta.data.items[i].value+']')
			res.render('graph', {title:'SGA', lista: lista, nome: '\'Total SGA\''});
		})
		.catch(erro => {
			console.log('Erro ao ler JSON da API REST.')
			res.render('error', {error: erro})
		})
})

router.get('/resources/pga', function(req, res, next) {
	axios.get('http://localhost:8080/ords/dbmonitoring/resources/src')
		.then(resposta => {
			lista = []
			for(i = 0; i < resposta.data.items.length; i++)
				if(resposta.data.items[i].origin == "PGA") lista.push('[\''+resposta.data.items[i].name+'\','+resposta.data.items[i].value+']')
			res.render('graph', {title:'PGA', lista: lista, nome: '\'Total PGA\''});
		})
		.catch(erro => {
			console.log('Erro ao ler JSON da API REST.')
			res.render('error', {error: erro})
		})
})

module.exports = router;
