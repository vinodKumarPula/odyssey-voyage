const resolvers = {
  Query: {
    locations: (_, __, { dataSources }) => {
      return dataSources.locationsAPI.getAllLocations();
    },
    location: (_, { id }, { dataSources }) => {
      cosole.log('checking agent',data);
      return dataSources.locationsAPI.getLocation(id);
    },
  },
};

module.exports = resolvers;
