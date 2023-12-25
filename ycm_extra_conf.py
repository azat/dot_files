def Settings(**kwargs):
    if kwargs['language'] == 'rust':
        return {
            'ls': {
                'rust': {
                    'all_features': True,
                }
            }
        }
